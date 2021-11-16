const expect = require('chai').expect;
const oracledb = require("oracledb");

describe("Database Availability", () => {
    
    /*
     We should never put actual credentials in the code, not even the test code
     So we load the actual credentials from a json-file that should have this structure:
     { "usern":"", "password":"" }
    */
   const credentials = require("../credentials.json");
    
    async function getConnection() {
        return await oracledb.getConnection({
            connectString   : "localhost:1523/XEPDB1",
            user            : credentials.user,
            password        : credentials.password  
        });
    } 

    /* Very basic check that our database adapter can create a connection object */
    it("Connection can be created", async () => {
        const connection = await getConnection();

        expect(connection).to.be.an("object");

        await connection.close();
    });

    /* A second check to verify we can actually select from the database */
    it("Connection allows simple SELECT", async () => {
        const connection = await getConnection();

        const resultSet = await connection.execute("select 1 from dual");
        expect(resultSet)
            .to.haveOwnProperty("rows")
            .that.deep.equal([[1]]);

        await connection.close();
    });

    /* High-level check if there are any invalid objects in the database */
    it("Database contains no invalid objects", async () => {
        const connection = await getConnection();

        const resultSet = await connection.execute(
            `select  object_name
                    ,object_type
                from user_objects
                where status != 'VALID'
            `
        );

        const results = resultSet.rows
            .map(entry => entry[0]+" ("+entry[1]+")")
            .join("\n");
        expect(results).to.be.empty;

        await connection.close;
    });
});
