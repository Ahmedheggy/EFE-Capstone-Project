package com.visualpathit.account.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.Statement;

@Controller
public class HealthCheckController {

    @Autowired
    private DataSource dataSource;

    @RequestMapping(value = "/healthz", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<String> healthCheck() {
        try (Connection connection = dataSource.getConnection();
                Statement statement = connection.createStatement()) {
            statement.execute("SELECT 1");
            return new ResponseEntity<>("OK", HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>("Service Unavailable: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
