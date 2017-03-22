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

    // Get all the db users.
    router.get("/users", function(req, res) {
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
    });

    // Get specific user data by phone.
    router.get("/users/byphone/:phone", function(req, res) {
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
    });

    // Get specific user data by email.
    router.get("/users/byemail/:email", function(req, res) {
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
    });

    // Insert an user into the db.
    router.post("/users", function(req, res) {
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
    });

    // Modify an user with a specific id.
    router.put("/users/:id", function(req, res) {
        var query = "UPDATE ?? SET ?? = ? WHERE ?? = ?";
        if (req.body.field === "password") {
            var table = ["user", req.body.field, md5(req.body.value), "id", req.params.id];
        }
        else {
            var table = ["user", req.body.field, req.body.value, "id", req.params.id];
        }
        query = mysql.format(query, table);
        connection.query(query, function(err, rows) {
            if (err) {
                res.json({ "Error": true, "Message": "Error executing MySQL query" });
            } else {
                res.json({ "Error": false, "Message": "Updated the password for the user with id " + req.params.id });
            }
        });
    });

    // Deletes an user with a specific id.
    router.delete("/users/:id", function(req, res) {
        var query = "DELETE from ?? WHERE ??=?";
        var table = ["user", "phone", req.params.id];
        query = mysql.format(query, table);
        connection.query(query, function(err, rows) {
            if (err) {
                res.json({ "Error": true, "Message": "Error executing MySQL query" });
            } else {
                res.json({ "Error": false, "Message": "Deleted the user with id " + req.params.id });
            }
        });
    });

    // Get the user payment data of a specific user.
    router.get("/paymentinfo/:user_id", function(req, res) {
        var query = "SELECT * FROM ??";
        var table = ["payment_method"];
        query = mysql.format(query, table);
        connection.query(query, function(err, rows) {
            if (err) {
                res.json({ "Error": true, "Message": "Error executing MySQL query" });
            } else {
                res.json({ "Error": false, "Message": "Success", "PaymentData": rows });
            }
        });
    });

    // Insert a payment info of an specific user.
    router.post("/paymentinfo", function(req, res) {
        var query = "INSERT INTO ??(??,??,??,??,??,??,??,??,??,??,??) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
        var table = ["payment_method", "user_id", "type", "number",
                     "expireDate", "name", "country", "province", "city",
                     "postalCode", "adress", "phone", req.body.user_id,
                     req.body.type, req.body.number, req.body.expireDate, req.body.name, 
                     req.body.country, req.body.province, req.body.city,
                     req.body.postalCode, req.body.adress, req.body.phone];
        query = mysql.format(query, table);
        console.log(query);
        connection.query(query, function(err, rows) {
            if (err) {
                res.json({ "Error": true, "Message": err });
            } else {
                res.json({ "Error": false, "Message": "User Payment Information Added !" });
            }
        });
    });
}

module.exports = REST_ROUTER;
