import * as admin from "firebase-admin";
    try {
      const actor = await getAuthorizedAdminActor(
        request.auth?.uid,
        "canManageBrands",
      );

      const payload = normalizeBrandPayload(
        (request.data as CreateBrandRequest | undefined)?.brand,
      );

      const brandRef = db.collection("brands").doc();
      const brandId = brandRef.id;
      let auditLogId = "";

      await db.runTransaction(async (tx) => {
        const slugQuery = db
          .collection("brands")
          .where("slug", "==", payload.slug)
          .limit(1);

        const slugSnap = await tx.get(slugQuery);
        if (!slugSnap.empty) {
          throw new HttpsError(
            "already-exists",
            "A brand with the same slug already exists.",
          );
        }

        const sortQuery = db
          .collection("brands")
          .where("sortOrder", "==", payload.sortOrder)
          .limit(1);

        const sortSnap = await tx.get(sortQuery);
        if (!sortSnap.empty) {
          throw new HttpsError(
            "already-exists",
            "Sort number already exists for another brand. Please use another.",
          );
        }

        tx.set(brandRef, buildBrandDoc(brandId, payload));

        const logRef = newAdminAuditLogRef();
        auditLogId = logRef.id;

        tx.set(
          logRef,
          buildAdminAuditLogDoc(logRef.id, actor, {
            action: "create_brand",
            module: "brands",
            targetType: "brand",
            targetId: brandId,
            targetTitle: payload.nameEn,
            status: "success",
            beforeData: null,
            afterData: buildAuditAfterData(brandId, payload),
            metadata: {
              sortOrder: payload.sortOrder,
              isFeatured: payload.isFeatured,
              showOnHome: payload.showOnHome,
              isActive: payload.isActive,
            },
            eventSource: "server_action",
          }),
        );
      });

      return {
        success: true,
        brandId,
        auditLogId,
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      logger.error("createBrand failed", error);
      throw new HttpsError("internal", "Failed to create brand.");
    }
  },
);