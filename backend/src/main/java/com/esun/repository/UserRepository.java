package com.esun.repository;

import com.esun.model.User;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class UserRepository {

    private final JdbcTemplate jdbcTemplate;

    public UserRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /** 查詢所有使用者 -> sp_get_all_users() */
    public List<User> findAll() {
        return jdbcTemplate.query(
                "SELECT * FROM sp_get_all_users()",
                userRowMapper()
        );
    }

    private RowMapper<User> userRowMapper() {
        return (rs, rowNum) -> new User(
                rs.getString("user_id"),
                rs.getString("user_name"),
                rs.getString("email"),
                rs.getString("account")
        );
    }
}
