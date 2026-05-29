package com.esun.config;

import jakarta.servlet.ReadListener;
import jakarta.servlet.ServletInputStream;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;
import org.springframework.web.util.HtmlUtils;

import java.io.*;
import java.nio.charset.StandardCharsets;

/**
 * XSS 防護：Request Wrapper
 * - URL 參數（getParameter）：HTML 跳脫
 * - JSON Body（getInputStream/getReader）：HTML 跳脫字串值
 */
public class XssRequestWrapper extends HttpServletRequestWrapper {

    private final byte[] sanitizedBody;

    public XssRequestWrapper(HttpServletRequest request) throws IOException {
        super(request);
        byte[] raw = request.getInputStream().readAllBytes();
        String body = new String(raw, StandardCharsets.UTF_8);
        // 僅跳脫 JSON 字串值中的 XSS 字元（不跳脫 JSON 結構本身）
        sanitizedBody = sanitizeJsonBody(body).getBytes(StandardCharsets.UTF_8);
    }

    // 跳脫 URL 參數（防止 Reflected XSS）
    @Override
    public String getParameter(String name) {
        String value = super.getParameter(name);
        return value != null ? HtmlUtils.htmlEscape(value) : null;
    }

    @Override
    public String[] getParameterValues(String name) {
        String[] values = super.getParameterValues(name);
        if (values == null) return null;
        String[] escaped = new String[values.length];
        for (int i = 0; i < values.length; i++) {
            escaped[i] = values[i] != null ? HtmlUtils.htmlEscape(values[i]) : null;
        }
        return escaped;
    }

    // 回傳已處理的 Body Stream
    @Override
    public ServletInputStream getInputStream() {
        ByteArrayInputStream byteStream = new ByteArrayInputStream(sanitizedBody);
        return new ServletInputStream() {
            @Override public int read() { return byteStream.read(); }
            @Override public boolean isFinished() { return byteStream.available() == 0; }
            @Override public boolean isReady() { return true; }
            @Override public void setReadListener(ReadListener l) {}
        };
    }

    @Override
    public BufferedReader getReader() {
        return new BufferedReader(new InputStreamReader(getInputStream(), StandardCharsets.UTF_8));
    }

    /**
     * 跳脫 JSON 字串值中的 <, >, ", ', & 等 XSS 字元
     * 僅處理 JSON 字串值（雙引號內），不影響 JSON 結構
     */
    private String sanitizeJsonBody(String json) {
        if (json == null || json.isBlank()) return json;
        StringBuilder sb = new StringBuilder();
        boolean inString = false;
        boolean escaped  = false;
        for (int i = 0; i < json.length(); i++) {
            char c = json.charAt(i);
            if (escaped) {
                sb.append(c);
                escaped = false;
                continue;
            }
            if (c == '\\' && inString) {
                sb.append(c);
                escaped = true;
                continue;
            }
            if (c == '"') {
                inString = !inString;
                sb.append(c);
                continue;
            }
            // 僅在字串值內跳脫 XSS 字元
            if (inString) {
                switch (c) {
                    case '<' -> sb.append("&lt;");
                    case '>' -> sb.append("&gt;");
                    case '&' -> sb.append("&amp;");
                    default  -> sb.append(c);
                }
            } else {
                sb.append(c);
            }
        }
        return sb.toString();
    }
}
