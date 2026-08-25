// Edge function that sends Firebase Cloud Messaging (FCM) push notifications
// for offer workflow events. It reads the offer from the database, resolves the
// people to notify, and delivers the message to every registered device.
//
// Deploy: supabase functions deploy push-notification
// Secrets: supabase secrets set FCM_SERVICE_ACCOUNT="$(jq -c . service-account.json)"

import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false } },
);

type SupabaseOffer = {
  id: string;
  reference_number: string | null;
  request_title: string | null;
  requester_id: string | null;
  sales_officer_id: string | null;
  assigned_role: string | null;
  rejection_reason: string | null;
};

type PushMessage = {
  title: string;
  body: string;
  data: Record<string, string>;
};

const ROLE_RESPONSIBLE = "responsible_officer";

Deno.serve(async (req) => {
  try {
    const body = await req.json().catch(() => ({}));
    const offerId: string | undefined = body?.offer_id;
    const event: string | undefined = body?.event;
    const extraReason: string | undefined = body?.rejection_reason;

    if (!offerId || !event) {
      return json({ error: "offer_id and event are required" }, 400);
    }

    const { data: offer, error: offerError } = await supabase
      .from("offers")
      .select(
        "id, reference_number, request_title, requester_id, sales_officer_id, assigned_role, rejection_reason",
      )
      .eq("id", offerId)
      .single();

    if (offerError || !offer) {
      return json({ error: "offer not found" }, 404);
    }

    const message = buildMessage(offer, event, extraReason ?? offer.rejection_reason);
    if (!message) {
      // No message for this event combination; nothing to do.
      return json({ ok: true, skipped: true });
    }

    const targetIds = await resolveTargets(offer, event);
    if (targetIds.length === 0) {
      return json({ ok: true, skipped: true, targets: 0 });
    }

    const { data: tokenRows } = await supabase
      .from("device_tokens")
      .select("id, token")
      .in("user_id", targetIds);

    const tokens = (tokenRows ?? []) as { id: string; token: string }[];
    if (tokens.length === 0) {
      return json({ ok: true, skipped: true, targets: targetIds.length, devices: 0 });
    }

    const { ok, sent, removed } = await sendPush(tokens, message);

    return json({ ok, sent, removed });
  } catch (error) {
    console.error("push-notification failed", error);
    return json({ error: String(error) }, 500);
  }
});

function buildMessage(
  offer: SupabaseOffer,
  event: string,
  rejectionReason: string | null,
): PushMessage | null {
  const ref = offer.reference_number ?? offer.id.slice(0, 8).toUpperCase();
  const title = offer.request_title || "طلب";

  switch (event) {
    case "new":
      return {
        title: "طلب جديد 📋",
        body: `طلب جديد ${ref}: ${title}`,
        data: { offer_id: offer.id, event, reference_number: ref },
      };
    case "pending_installation":
      return {
        title: "جاهز للتركيب 🔧",
        body: `تمت الموافقة على ${ref} وأصبح الطلب بانتظار التركيب (${title})`,
        data: { offer_id: offer.id, event, reference_number: ref },
      };
    case "approved":
      return {
        title: "تم قبول الطلب ✅",
        body: `تم قبول طلبك ${ref}: ${title}`,
        data: { offer_id: offer.id, event, reference_number: ref },
      };
    case "rejected":
      return {
        title: "تم رفض الطلب ❌",
        body: `تم رفض طلبك ${ref}: ${title}${rejectionReason ? `\nالسبب: ${rejectionReason}` : ""}`,
        data: { offer_id: offer.id, event, reference_number: ref },
      };
    case "completed":
      return {
        title: "اكتمل الطلب 🎉",
        body: `اكتمل تنفيذ طلبك ${ref}: ${title}`,
        data: { offer_id: offer.id, event, reference_number: ref },
      };
    case "cancelled":
      return {
        title: "تم إلغاء الطلب 🚫",
        body: `تم إلغاء طلبك ${ref}: ${title}`,
        data: { offer_id: offer.id, event, reference_number: ref },
      };
    case "resubmitted":
    case "reopened":
      return {
        title: "تمت إعادة إرسال الطلب 🔄",
        body: `تم إعادة إرسال ${ref} للمراجعة مرة أخرى: ${title}`,
        data: { offer_id: offer.id, event, reference_number: ref },
      };
    case "edit_requested":
      return {
        title: "طلب تعديل ✏️",
        body: `هناك طلب تعديل جديد على ${ref}: ${title}`,
        data: { offer_id: offer.id, event, reference_number: ref },
      };
    case "edit_approved":
      return {
        title: "تمت الموافقة على التعديل ✅",
        body: `تمت الموافقة على تعديل طلبك ${ref}، يمكنك الآن تعديله`,
        data: { offer_id: offer.id, event, reference_number: ref },
      };
    case "edit_rejected":
      return {
        title: "تم رفض طلب التعديل ❌",
        body: `تم رفض طلب تعديلك على ${ref}`,
        data: { offer_id: offer.id, event, reference_number: ref },
      };
    default:
      return null;
  }
}

async function resolveTargets(
  offer: SupabaseOffer,
  event: string,
): Promise<string[]> {
  const ids = new Set<string>();

  const add = (...list: Array<string | null | undefined>) => {
    for (const id of list) {
      if (id) ids.add(id);
    }
  };

  const addByRole = async (...roles: string[]) => {
    const { data } = await supabase.from("users").select("id").in("role", roles);
    for (const row of data ?? []) add(row.id as string);
  };

  const creator = () => {
    // Notify the person who created the request (requester is the creator).
    return offer.requester_id ?? offer.sales_officer_id;
  };

  const assignedRoleUsers = async () => {
    const role = offer.assigned_role;
    if (role && role !== "company_officer" && role !== ROLE_RESPONSIBLE) {
      await addByRole(role);
    }
  };

  switch (event) {
    case "new":
      // Notify the factory / installation team and the responsible officer.
      await assignedRoleUsers();
      if (offer.assigned_role === "company_officer") await addByRole("company_officer");
      await addByRole(ROLE_RESPONSIBLE);
      break;
    case "pending_installation":
      // Factory approved; the installation team and the responsible officer
      // are informed.
      await addByRole("company_officer", ROLE_RESPONSIBLE);
      break;
    case "approved":
    case "rejected":
    case "completed":
    case "cancelled":
    case "edit_approved":
    case "edit_rejected":
      add(creator());
      if (event === "completed" || event === "cancelled") {
        await addByRole(ROLE_RESPONSIBLE);
      }
      break;
    case "edit_requested":
      await addByRole(ROLE_RESPONSIBLE);
      break;
    case "resubmitted":
    case "reopened":
      await assignedRoleUsers();
      if (offer.assigned_role === "company_officer") await addByRole("company_officer");
      await addByRole(ROLE_RESPONSIBLE);
      break;
    default:
      add(creator());
  }

  return [...ids];
}

async function sendPush(
  devices: { id: string; token: string }[],
  message: PushMessage,
): Promise<{ ok: boolean; sent: number; removed: number }> {
  const serviceAccountJson = Deno.env.get("FCM_SERVICE_ACCOUNT");
  if (!serviceAccountJson) {
    console.error("FCM_SERVICE_ACCOUNT secret is not set");
    return { ok: false, sent: 0, removed: 0 };
  }

  let account: {
    client_email: string;
    private_key: string;
    project_id: string;
  };
  try {
    account = JSON.parse(serviceAccountJson);
  } catch (e) {
    console.error("FCM_SERVICE_ACCOUNT is not valid JSON", e);
    return { ok: false, sent: 0, removed: 0 };
  }

  const client = new JWT({
    email: account.client_email,
    key: account.private_key,
    scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
  });

  const { token: accessToken } = await client.getAccessToken();
  if (!accessToken) {
    return { ok: false, sent: 0, removed: 0 };
  }

  const endpoint =
    `https://fcm.googleapis.com/v1/projects/${account.project_id}/messages:send`;

  let sent = 0;
  const removed: string[] = [];

  for (const device of devices) {
    try {
      const res = await fetch(endpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token: device.token,
            notification: { title: message.title, body: message.body },
            data: message.data,
            android: {
              notification: { channel_id: "mta_orders" },
            },
          },
        }),
      });

      if (res.ok) {
        sent++;
      } else {
        const errorBody = await res.text();
        // The token is no longer valid; stop trying to reach this device.
        if (res.status === 404 || errorBody.includes("UNREGISTERED")) {
          removed.push(device.id);
        } else {
          console.error("FCM send error", res.status, errorBody.slice(0, 300));
        }
      }
    } catch (e) {
      console.error("FCM send exception", String(e).slice(0, 300));
    }
  }

  if (removed.length > 0) {
    await supabase.from("device_tokens").delete().in("id", removed);
  }

  return { ok: true, sent, removed: removed.length };
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}