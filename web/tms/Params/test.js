function myFunction() {
    var sql = require("mssql");
    
    var config = {
        user: 'TMS',
        password: '@T#$12121',
        server: '10.16.9.16', 
        port:1433,
        database: 'BOSNET1' 
    };

    // connect to your database
    sql.connect(config, function (err) {

        if (err) console.log(err);

        // create Request object
        var request = new sql.Request();

        // query to the database and get the records
        request.query('select param, value from bosnet1.dbo.TMS_PreRouteParams where RunId = (SELECT distinct OriRunId FROM BOSNET1.dbo.TMS_Progress where runID = \'20180620_103900602\')', function (err, recordset) {

            if (err) console.log(err);
            console.log('test');
            // send records as a response
            res.send(recordset);

        });
    });
}