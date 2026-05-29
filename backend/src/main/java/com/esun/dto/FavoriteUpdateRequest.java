package com.esun.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.math.BigDecimal;

/**
 * 更改喜好金融商品 Request DTO
 */
@Data
public class FavoriteUpdateRequest {

    @NotBlank(message = "產品名稱不得為空")
    @Size(max = 200, message = "產品名稱長度不得超過200字")
    private String productName;

    @NotNull(message = "產品價格不得為空")
    @DecimalMin(value = "0.01", message = "產品價格必須大於0")
    @Digits(integer = 16, fraction = 2, message = "產品價格格式不正確")
    private BigDecimal price;

    @NotNull(message = "手續費率不得為空")
    @DecimalMin(value = "0", message = "手續費率不得為負數")
    @DecimalMax(value = "1", message = "手續費率不得超過100%")
    @Digits(integer = 1, fraction = 4, message = "手續費率格式不正確 (ex: 0.01)")
    private BigDecimal feeRate;

    @NotBlank(message = "扣款帳號不得為空")
    @Size(max = 20, message = "扣款帳號長度不得超過20字")
    @Pattern(regexp = "^[0-9]+$", message = "扣款帳號只能包含數字")
    private String account;

    @NotNull(message = "購買數量不得為空")
    @Min(value = 1, message = "購買數量至少為1")
    private Integer purchaseQuantity;
}
