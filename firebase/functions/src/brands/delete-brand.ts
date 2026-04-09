import * as admin from "firebase-admin";
        "canManageBrands",
      );

      const payload = (request.data ?? {}) as DeleteBrandRequest;
      const brandId = asTrimmedString(payload.brandId);
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
        const productsCount = asInt(currentData.productsCount, 0);

        if (productsCount > 0) {
          throw new HttpsError(
            "failed-precondition",
            `This brand cannot be deleted because it contains ${productsCount} product(s).`,
          );
        }

        tx.delete(brandRef);

        const logRef = newAdminAuditLogRef();
        auditLogId = logRef.id;

        tx.set(
          logRef,
          buildAdminAuditLogDoc(logRef.id, actor, {
            action: "delete_brand",
            module: "brands",
            targetType: "brand",
            targetId: brandId,
            targetTitle: asTrimmedString(currentData.nameEn) || brandId,
            status: "success",
            reason,
            beforeData,
            afterData: null,
            metadata: {
              deletedImagePath: asTrimmedString(currentData.imagePath),
              deletedThumbPath: asTrimmedString(currentData.thumbPath),
              deletedLogoUrl: asTrimmedString(currentData.logoUrl),
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

      logger.error("deleteBrand failed", error);
      throw new HttpsError("internal", "Failed to delete brand.");
    }
  },
);