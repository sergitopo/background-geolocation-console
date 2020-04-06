import Sequelize from 'sequelize';
import definedSequelizeDb from './define-sequelize-db';

const CompanyModel = definedSequelizeDb.define(
  'companies',
  {
    id: {
      type: Sequelize.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    company_token: { type: Sequelize.TEXT },
    created_at: { type: Sequelize.DATE },
    updated_at: { type: Sequelize.DATE },
    name: { type: Sequelize.TEXT },
    first_name: { type: Sequelize.TEXT },
    phone_number: { type: Sequelize.TEXT },
    id_number: { type: Sequelize.TEXT },
    trip_reason: { type: Sequelize.TEXT },
    accomodation: { type: Sequelize.TEXT },
    recently_visited_countries: { type: Sequelize.TEXT },
    form_info: { type: Sequelize.TEXT },
    has_symtoms: { type: Sequelize.BOOLEAN },
    accomodation_lat: { type: Sequelize.DOUBLE },
    accomodation_lon: { type: Sequelize.DOUBLE },
  },
  {
    timestamps: false,
  }
);

CompanyModel.associate = models => {
  models.Company.hasMany(models.Device, { foreignKey: 'company_id' });
  models.Company.hasMany(models.Location, { foreignKey: 'company_id' });
};

export default CompanyModel;
