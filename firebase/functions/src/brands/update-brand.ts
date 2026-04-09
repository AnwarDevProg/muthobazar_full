import * as admin from "firebase-admin";
        const productsCount = asInt(currentData.productsCount, 0);

        const slugQuery = db
          .collection("brands")
          .where("slug", "==", payload.slug)
          .limit(10);
        const slugSnap = await tx.get(slugQuery);
        const slugConflict = slugSnap.docs.find((doc) => doc.id !== brandId);
        if (slugConflict) {
          throw new HttpsError(
            "already-exists",
            "A brand with the same slug already exists.",
          );
        }

        const sortQuery = db
          .collection("brands")
          .where("sortOrder", "==", payload.sortOrder)
          .limit(10);
        const sortSnap = await tx.get(sortQuery);
        const sortConflict = sortSnap.docs.find((doc) => doc.id !== brandId);
        if (sortConflict) {
          throw new HttpsError(
            "already-exists",
            "Sort number already exists for another brand. Please use another.",
          );
        }

        tx.set(
          brandRef,
          buildUpdatedBrandDoc(payload, productsCount),
          { merge: true },
        );

        const logRef = newAdminAuditLogRef();
        auditLogId = logRef.id;

        tx.set(
          logRef,
          buildAdminAuditLogDoc(logRef.id, actor, {
            action: "update_brand",
            module: "brands",
            targetType: "brand",
            targetId: brandId,
            targetTitle: payload.nameEn,
            status: "success",
            beforeData,
            afterData: buildAuditAfterData(brandId, payload, productsCount),
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

      logger.error("updateBrand failed", error);
      throw new HttpsError("internal", "Failed to update brand.");
    }
  },
);