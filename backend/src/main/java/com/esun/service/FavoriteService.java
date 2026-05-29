package com.esun.service;

import com.esun.dto.FavoriteAddRequest;
import com.esun.dto.FavoriteUpdateRequest;
import com.esun.model.FavoriteDetail;
import com.esun.repository.FavoriteRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.NoSuchElementException;

/**
 * 業務層 - 金融商品喜好紀錄
 *
 * @Transactional 放在 Service 上：
 *  - 新增：同時異動 products + like_list
 *  - 更改：同時異動 products + like_list
 *  - 刪除：同時刪除 like_list + products
 * 任何步驟失敗均會 rollback，避免資料錯亂
 */
@Service
@Transactional
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;

    public FavoriteService(FavoriteRepository favoriteRepository) {
        this.favoriteRepository = favoriteRepository;
    }

    // ----------------------------------------------------------
    // 查詢喜好清單（唯讀）
    // ----------------------------------------------------------
    @Transactional(readOnly = true)
    public List<FavoriteDetail> getFavorites(String userId) {
        return favoriteRepository.getFavorites(userId);
    }

    // ----------------------------------------------------------
    // 新增喜好金融商品
    // 同時 INSERT products + like_list（Transaction 保護）
    // ----------------------------------------------------------
    public FavoriteDetail addFavorite(FavoriteAddRequest req) {
        Integer sn = favoriteRepository.addFavorite(
                req.getUserId(),
                req.getProductName(),
                req.getPrice(),
                req.getFeeRate(),
                req.getAccount(),
                req.getPurchaseQuantity()
        );
        // 查回完整資料
        return favoriteRepository.getFavorites(req.getUserId())
                .stream()
                .filter(f -> f.getSn().equals(sn))
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("新增後查詢失敗"));
    }

    // ----------------------------------------------------------
    // 更改喜好金融商品
    // 同時 UPDATE products + like_list（Transaction 保護）
    // ----------------------------------------------------------
    public FavoriteDetail updateFavorite(Integer sn, String userId, FavoriteUpdateRequest req) {
        boolean updated = favoriteRepository.updateFavorite(
                sn,
                req.getProductName(),
                req.getPrice(),
                req.getFeeRate(),
                req.getAccount(),
                req.getPurchaseQuantity()
        );
        if (!updated) {
            throw new NoSuchElementException("找不到喜好清單 SN: " + sn);
        }
        return favoriteRepository.getFavorites(userId)
                .stream()
                .filter(f -> f.getSn().equals(sn))
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("更新後查詢失敗"));
    }

    // ----------------------------------------------------------
    // 刪除喜好金融商品
    // 同時 DELETE like_list + products（Transaction 保護）
    // ----------------------------------------------------------
    public void deleteFavorite(Integer sn) {
        boolean deleted = favoriteRepository.deleteFavorite(sn);
        if (!deleted) {
            throw new NoSuchElementException("找不到喜好清單 SN: " + sn);
        }
    }
}
