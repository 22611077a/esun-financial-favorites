package com.esun.repository;

import com.esun.model.FavoriteDetail;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public class FavoriteRepository {

    private final JdbcTemplate jdbcTemplate;

    public FavoriteRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    // ----------------------------------------------------------
    // 新增喜好金融商品 -> sp_add_favorite(...)
    // * 同時異動 products + like_list，由 Spring @Transactional 管控
    // ----------------------------------------------------------
    public Integer addFavorite(String userId, String productName, BigDecimal price,
                               BigDecimal feeRate, String account, Integer purchaseQuantity) {
        SimpleJdbcCall call = new SimpleJdbcCall(jdbcTemplate)
                .withFunctionName("sp_add_favorite");

        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("p_user_id",           userId)
                .addValue("p_product_name",      productName)
                .addValue("p_price",             price)
                .addValue("p_fee_rate",          feeRate)
                .addValue("p_account",           account)
                .addValue("p_purchase_quantity", purchaseQuantity);

        return call.executeFunction(Integer.class, params);
    }

    // ----------------------------------------------------------
    // 查詢喜好清單 -> sp_get_favorites(p_user_id)
    // ----------------------------------------------------------
    public List<FavoriteDetail> getFavorites(String userId) {
        return jdbcTemplate.query(
                "SELECT * FROM sp_get_favorites(?)",
                favoriteRowMapper(),
                userId
        );
    }

    // ----------------------------------------------------------
    // 更改喜好金融商品 -> sp_update_favorite(...)
    // * 同時異動 products + like_list，由 Spring @Transactional 管控
    // ----------------------------------------------------------
    public boolean updateFavorite(Integer sn, String productName, BigDecimal price,
                                  BigDecimal feeRate, String account, Integer purchaseQuantity) {
        SimpleJdbcCall call = new SimpleJdbcCall(jdbcTemplate)
                .withFunctionName("sp_update_favorite");

        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("p_sn",                sn)
                .addValue("p_product_name",      productName)
                .addValue("p_price",             price)
                .addValue("p_fee_rate",          feeRate)
                .addValue("p_account",           account)
                .addValue("p_purchase_quantity", purchaseQuantity);

        return Boolean.TRUE.equals(call.executeFunction(Boolean.class, params));
    }

    // ----------------------------------------------------------
    // 刪除喜好金融商品 -> sp_delete_favorite(p_sn)
    // * 同時刪除 like_list + products，由 Spring @Transactional 管控
    // ----------------------------------------------------------
    public boolean deleteFavorite(Integer sn) {
        SimpleJdbcCall call = new SimpleJdbcCall(jdbcTemplate)
                .withFunctionName("sp_delete_favorite");

        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("p_sn", sn);

        return Boolean.TRUE.equals(call.executeFunction(Boolean.class, params));
    }

    // ----------------------------------------------------------
    // RowMapper
    // ----------------------------------------------------------
    private RowMapper<FavoriteDetail> favoriteRowMapper() {
        return (rs, rowNum) -> {
            FavoriteDetail d = new FavoriteDetail();
            d.setSn(rs.getInt("sn"));
            d.setProductName(rs.getString("product_name"));
            d.setPrice(rs.getBigDecimal("price"));
            d.setFeeRate(rs.getBigDecimal("fee_rate"));
            d.setPurchaseQuantity(rs.getInt("purchase_quantity"));
            d.setAccount(rs.getString("account"));
            d.setTotalFee(rs.getBigDecimal("total_fee"));
            d.setTotalAmount(rs.getBigDecimal("total_amount"));
            d.setEmail(rs.getString("email"));
            d.setUserName(rs.getString("user_name"));
            return d;
        };
    }
}
