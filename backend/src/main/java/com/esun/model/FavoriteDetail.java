package com.esun.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;

/**
 * 喜好清單查詢結果（JOIN users + products + like_list）
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FavoriteDetail {
    private Integer    sn;
    private String     productName;
    private BigDecimal price;
    private BigDecimal feeRate;
    private Integer    purchaseQuantity;
    private String     account;
    private BigDecimal totalFee;
    private BigDecimal totalAmount;
    private String     email;
    private String     userName;
}
