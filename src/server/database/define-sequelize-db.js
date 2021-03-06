import Sequelize from 'sequelize';
import path from 'path';

// ENVIRONMENT VARIABLES :
// PORT (optional, defaulted to 8080) : http port server will listen to
// DB_CONNECTION_URL (defaulted to "sqlite://db/background-geolocation.db") : connection url used to connect to a db
//    Currently, only postgresql & sqlite dialect are supported
//    Sample pattern for postgresql connection url : postgres://<username>:<password>@<hostname>:<port>/<dbname>
const database = process.env.DATABASE_DATABASE || 'xxxxxx';
const username = process.env.DATABASE_USER || 'xxxxxx';
const password = process.env.DATABASE_PSW || 'xxxxxx';
const host = process.env.DATABASE_HOST || 'svlpgsql10.prodevelop.es';
const schema = process.env.DATABASE_SCHEMA || 'coronatrack';
const dialect = 'postgres';
const config = { database, username, password };
const options = {
  database,
  username,
  password,
  host,
  schema,
  dialect,
};
export default new Sequelize(options);
