package com.esun.controller;

import com.esun.common.ApiResponse;
import com.esun.dto.FavoriteAddRequest;
import com.esun.dto.FavoriteUpdateRequest;
import com.esun.model.FavoriteDetail;
import com.esun.service.FavoriteService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 展示層 - 金融商品喜好 RESTful API
 */
@RestController
@RequestMapping("/api/favorites")
@CrossOrigin(origins = "http://localhost:5173")
public class FavoriteController {

    private final FavoriteService favoriteService;

    public FavoriteController(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    /**
     * GET /api/favorites?userId={userId}
     * 查詢喜好金融商品清單（含帳號、總金額、總手續費、Email）
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<FavoriteDetail>>> getFavorites(
            @RequestParam String userId) {
        return ResponseEntity.ok(ApiResponse.ok(favoriteService.getFavorites(userId)));
    }

    /**
     * POST /api/favorites
     * 新增喜好金融商品（同時異動 products + like_list）
     */
    @PostMapping
    public ResponseEntity<ApiResponse<FavoriteDetail>> addFavorite(
            @Valid @RequestBody FavoriteAddRequest request) {
        FavoriteDetail created = favoriteService.addFavorite(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("新增成功", created));
    }

    /**
     * PUT /api/favorites/{sn}?userId={userId}
     * 更改喜好金融商品資訊（同時異動 products + like_list）
     */
    @PutMapping("/{sn}")
    public ResponseEntity<ApiResponse<FavoriteDetail>> updateFavorite(
            @PathVariable Integer sn,
            @RequestParam String userId,
            @Valid @RequestBody FavoriteUpdateRequest request) {
        FavoriteDetail updated = favoriteService.updateFavorite(sn, userId, request);
        return ResponseEntity.ok(ApiResponse.ok("更新成功", updated));
    }

    /**
     * DELETE /api/favorites/{sn}
     * 刪除喜好金融商品（同時刪除 like_list + products）
     */
    @DeleteMapping("/{sn}")
    public ResponseEntity<ApiResponse<Void>> deleteFavorite(@PathVariable Integer sn) {
        favoriteService.deleteFavorite(sn);
        return ResponseEntity.ok(ApiResponse.ok("刪除成功", null));
    }
}
