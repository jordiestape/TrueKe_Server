// token generation
var md5 = require("md5");
var MAGIC_NUMBER = 0x21412436587232;
var TRUEKE_TOKEN = md5(MAGIC_NUMBER);

var mysql = require("mysql");

function REST_ROUTER(router, connection, md5) {
    var self = this;
    self.handleRoutes(router, connection, md5);
}

REST_ROUTER.prototype.handleRoutes = function(router, connection, md5) {
    var self = this;
    router.get("/", function(req, res) {
        res.json({ "Message": "We are working hard on TrueKe!" });
    });


    // AUTHENTICATION MECHANISM
    // ----- ----- ----- -----

    router.post("/authenticate", function(req, res) {
        var query = "SELECT * FROM ?? WHERE ??=? and ??=?";
        if (req.body.email) {
            var table = ["user", "email", req.body.email, "password", md5(req.body.password)];
            query = mysql.format(query, table);
            connection.query(query, function(err, rows) {
                if (err) {
                    res.json({ "Error": true, "Message": "Failed authentication" });
                } else {
                    res.json({ "Error": false, "Message": "Success", "Token": TRUEKE_TOKEN });
                }
            });
        } else if (req.body.phone) {

        } else {
            res.json({ "Error": true, "Message": "Failed authentication" });
        }
    });


    // USER TABLE
    // ----- ----- ----- -----

    // Get all the db users.
    router.get("/users", function(req, res) {
        var token = req.headers["token"];
        if (token == TRUEKE_TOKEN) {
            var query = "SELECT * FROM ??";
            var table = ["user"];
            query = mysql.format(query, table);
            connection.query(query, function(err, rows) {
                if (err) {
                    res.json({ "Error": true, "Message": "Error executing MySQL query" });
                } else {
                    res.json({ "Error": false, "Message": "Success", "Users": rows });
                }
            });
        } else {
            res.json({ "Error": false, "Message": "Fail to access to API REST. You are not authenticated" });
        }
    });

    // Get specific user data by phone.
    router.get("/users/byphone/:phone", function(req, res) {
        var token = req.headers["token"];
        if (token == TRUEKE_TOKEN) {
            var query = "SELECT * FROM ?? WHERE ??=?";
            var table = ["user", "phone", req.params.phone];
            query = mysql.format(query, table);
            connection.query(query, function(err, rows) {
                if (err) {
                    res.json({ "Error": true, "Message": "Error executing MySQL query" });
                } else {
                    res.json({ "Error": false, "Message": "Success", "Users": rows });
                }
            });
        } else {
            res.json({ "Error": false, "Message": "Fail to access to API REST. You are not authenticated" });
        }

    });

    // Get specific user data by email.
    router.get("/users/byemail/:email", function(req, res) {
        var token = req.headers["token"];
        if (token == TRUEKE_TOKEN) {
            var query = "SELECT * FROM ?? WHERE ??=?";
            var table = ["user", "email", req.params.email];
            query = mysql.format(query, table);
            connection.query(query, function(err, rows) {
                if (err) {
                    res.json({ "Error": true, "Message": "Error executing MySQL query" });
                } else {
                    res.json({ "Error": false, "Message": "Success", "Users": rows });
                }
            });
        } else {
            res.json({ "Error": false, "Message": "Fail to access to API REST. You are not authenticated" });
        }
    });

    // Insert an user into the db.
    router.post("/users", function(req, res) {
        var token = req.headers["token"];
        if (token == TRUEKE_TOKEN) {
            var query = "INSERT INTO ??(??,??,??,??,??) VALUES (?,?,?,?,?)";
            var table = ["user", "phone", "user", "password", "birthDate", "email", req.body.phone, req.body.user, md5(req.body.password), req.body.birthDate, req.body.email];
            query = mysql.format(query, table);
            connection.query(query, function(err, rows) {
                if (err) {
                    res.json({ "Error": true, "Message": "Error executing MySQL query" });
                } else {
                    res.json({ "Error": false, "Message": "User Added !" });
                }
            });
        } else {
            res.json({ "Error": false, "Message": "Fail to access to API REST. You are not authenticated" });
        }
    });

    // Modify an user with a specific id.
    router.put("/users/:id", function(req, res) {
        var token = req.headers["token"];
        if (token == TRUEKE_TOKEN) {
            var query = "UPDATE ?? SET ??=? WHERE ??=?";
            if (req.body.field === "password") {
                var table = ["user", req.body.field, md5(req.body.value), "id", req.params.id];
            } else {
                var table = ["user", req.body.field, req.body.value, "id", req.params.id];
            }
            query = mysql.format(query, table);
            connection.query(query, function(err, rows) {
                if (err) {
                    res.json({ "Error": true, "Message": "Error executing MySQL query" });
                } else {
                    res.json({ "Error": false, "Message": "Updated the field !" });
                }
            });
        } else {
            res.json({ "Error": false, "Message": "Fail to access to API REST. You are not authenticated" });
        }
    });

    // Deletes an user with a specific id.
    router.delete("/users/:id", function(req, res) {
        var token = req.headers["token"];
        if (token == TRUEKE_TOKEN) {
            var query = "DELETE from ?? WHERE ??=?";
            var table = ["user", "phone", req.params.id];
            query = mysql.format(query, table);
            connection.query(query, function(err, rows) {
                if (err) {
                    res.json({ "Error": true, "Message": "Error executing MySQL query" });
                } else {
                    res.json({ "Error": false, "Message": "User Deleted !" });
                }
            });
        } else {
            res.json({ "Error": false, "Message": "Fail to access to API REST. You are not authenticated" });
        }
    });


    // PAYMENT_METHOD TABLE
    // ----- ----- ----- -----

    // Get the user payment data of a specific user.
    router.get("/paymentinfo/:user_id", function(req, res) {
        var token = req.headers["token"];
        if (token == TRUEKE_TOKEN) {
            var query = "SELECT * FROM ?? WHERE ??=?";
            var table = ["payment_method", "user_id", req.params.user_id];
            query = mysql.format(query, table);
            connection.query(query, function(err, rows) {
                if (err) {
                    res.json({ "Error": true, "Message": "Error executing MySQL query" });
                } else {
                    res.json({ "Error": false, "Message": "Success", "Payment Information": rows });
                }
            });
        } else {
            res.json({ "Error": false, "Message": "Fail to access to API REST. You are not authenticated" });
        }
    });

    // Insert a payment info of an specific user.
    router.post("/paymentinfo", function(req, res) {
        var token = req.headers["token"];
        if (token == TRUEKE_TOKEN) {
            var query = "INSERT INTO ??(??,??,??,??,??,??,??,??,??,??,??) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
            var table = ["payment_method", "user_id", "type", "number",
                "expireDate", "name", "country", "province", "city",
                "postalCode", "adress", "phone", req.body.user_id,
                req.body.type, req.body.number, req.body.expireDate, req.body.name,
                req.body.country, req.body.province, req.body.city,
                req.body.postalCode, req.body.adress, req.body.phone
            ];
            query = mysql.format(query, table);
            connection.query(query, function(err, rows) {
                if (err) {
                    res.json({ "Error": true, "Message": err });
                } else {
                    res.json({ "Error": false, "Message": "User Payment Information Added !" });
                }
            });
        } else {
            res.json({ "Error": false, "Message": "Fail to access to API REST. You are not authenticated" });
        }
    });

    // Modify a shipment info.
    router.put("/paymentinfo/:id", function(req, res) {
        var token = req.headers["token"];
        if (token == TRUEKE_TOKEN) {
            var query = "UPDATE ?? SET ??=? WHERE ??=?";
            var table = ["payment_method", req.body.field, req.body.value, "id", req.params.id];
            query = mysql.format(query, table);
            connection.query(query, function(err, rows) {
                if (err) {
                    res.json({ "Error": true, "Message": "Error executing MySQL query" });
                } else {
                    res.json({ "Error": false, "Message": "Updated the field !" });
                }
            });
        } else {
            res.json({ "Error": false, "Message": "Fail to access to API REST. You are not authenticated" });
        }
    });

    // Delete a shipment info.
    router.delete("/paymentinfo/:id", function(req, res) {
        var token = req.headers["token"];
        if (token == TRUEKE_TOKEN) {
            var query = "DELETE FROM ?? WHERE ??=?";
            var table = ["payment_method", "id", req.params.id];
            query = mysql.format(query, table);
            connection.query(query, function(err, rows) {
                if (err) {
                    res.json({ "Error": true, "Message": "Error executing MySQL query" });
                } else {
                    res.json({ "Error": false, "Message": "Shipment Information Deleted !" });
                }
            });
        } else {
            res.json({ "Error": false, "Message": "Fail to access to API REST. You are not authenticated" });
        }
    });


    // SHIPMENT_METHOD TABLE
    // ----- ----- ----- -----

    // Get the user shipment info of a specific user.
    router.get("/shipmentinfo/:user_id", function(req, res) {
        var token = req.headers["token"];
        if (token == TRUEKE_TOKEN) {
            var query = "SELECT * FROM ?? WHERE ??=?";
            var table = ["shipment_method", "user_id", req.params.user_id];
            query = mysql.format(query, table);
            connection.query(query, function(err, rows) {
                if (err) {
                    res.json({ "Error": true, "Message": "Error executing MySQL query" });
                } else {
                    res.json({ "Error": false, "Message": "Success", "Shipment Information": rows });
                }
            });
        } else {
            res.json({ "Error": false, "Message": "Fail to access to API REST. You are not authenticated" });
        }
    });

    // Insert a user shipment info of an specific user.
    router.post("/shipmentinfo", function(req, res) {
        var token = req.headers["token"];
        if (token == TRUEKE_TOKEN) {
            var query = "INSERT INTO ??(??,??,??,??,??,??,??,??,??) VALUES (?,?,?,?,?,?,?,?,?)";
            var table = ["shipment_method", "user_id", "country", "province", "city",
                "postalCode", "adress", "name", "idCard", "phone", req.body.user_id,
                req.body.country, req.body.province, req.body.city, req.body.postalCode,
                req.body.adress, req.body.name, req.body.idCard, req.body.phone
            ];
            query = mysql.format(query, table);
            connection.query(query, function(err, rows) {
                if (err) {
                    res.json({ "Error": true, "Message": err });
                } else {
                    res.json({ "Error": false, "Message": "User Shipment Information Added !" });
                }
            });
        } else {
            res.json({ "Error": false, "Message": "Fail to access to API REST. You are not authenticated" });
        }
    });

    // Modify a shipment info.
    router.put("/shipmentinfo/:id", function(req, res) {
        var token = req.headers["token"];
        if (token == TRUEKE_TOKEN) {
            var query = "UPDATE ?? SET ??=? WHERE ??=?";
            var table = ["shipment_method", req.body.field, req.body.value, "id", req.params.id];
            query = mysql.format(query, table);
            connection.query(query, function(err, rows) {
                if (err) {
                    res.json({ "Error": true, "Message": "Error executing MySQL query" });
                } else {
                    res.json({ "Error": false, "Message": "Updated the field !" });
                }
            });
        } else {
            res.json({ "Error": false, "Message": "Fail to access to API REST. You are not authenticated" });
        }
    });

    // Delete a shipment info.
    router.delete("/shipmentinfo/:id", function(req, res) {
        var token = req.headers["token"];
        if (token == TRUEKE_TOKEN) {
            var query = "DELETE FROM ?? WHERE ??=?";
            var table = ["shipment_method", "id", req.params.id];
            query = mysql.format(query, table);
            connection.query(query, function(err, rows) {
                if (err) {
                    res.json({ "Error": true, "Message": "Error executing MySQL query" });
                } else {
                    res.json({ "Error": false, "Message": "Shipment Information Deleted !" });
                }
            });
        } else {
            res.json({ "Error": false, "Message": "Fail to access to API REST. You are not authenticated" });
        }
    });

}

module.exports = REST_ROUTER;
