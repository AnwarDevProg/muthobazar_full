import * as admin from "firebase-admin";
      const actor = await getAuthorizedAdminActor(
        request.auth?.uid,
        "canManageBrands",
      );

      const payload = (request.data ?? {}) as SetBrandActiveStateRequest;
      const brandId = asTrimmedString(payload.brandId);
      const isActive = asBool(payload.isActive, true);
      const reason = asNullableTrimmedString(payload.reason);

      requireNonEmpty(brandId, "brandId");

      const brandRef = db.collection("brands").doc(brandId);
      let auditLogId = "";

      await db.runTransaction(async (tx) => {
        const brandSnap = await tx.get(brandRef);
        if (!brandSnap.exists) {
          throw new HttpsError("not-found", "Brand was not found.");
        }

        const currentData = brandSnap.data() ?? {};
        const beforeData = asBrandSnapshot(currentData, brandId);

        tx.set(
          brandRef,
          {
            isActive,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            ...(reason ? { lastStatusChangeReason: reason } : {}),
          },
          { merge: true },
        );

        const afterData = {
          ...beforeData,
          isActive,
        };

        const logRef = newAdminAuditLogRef();
        auditLogId = logRef.id;

        tx.set(
          logRef,
          buildAdminAuditLogDoc(logRef.id, actor, {
            action: isActive ? "activate_brand" : "deactivate_brand",
            module: "brands",
            targetType: "brand",
            targetId: brandId,
            targetTitle: asTrimmedString(currentData.nameEn) || brandId,
            status: "success",
            reason,
            beforeData,
            afterData,
            metadata: {
              previousIsActive: asBool(currentData.isActive, true),
              nextIsActive: isActive,
            },
            eventSource: "server_action",
          }),
        );
      });

      return {
        success: true,
        brandId,
        isActive,
        auditLogId,
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      logger.error("setBrandActiveState failed", error);
      throw new HttpsError("internal", "Failed to update brand status.");
    }
  },
);