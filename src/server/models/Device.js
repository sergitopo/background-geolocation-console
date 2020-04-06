import { Op } from 'sequelize';

import { findOrCreate as findOrCreateCompany } from './Org';
import DeviceModel from '../database/DeviceModel';
import LocationModel from '../database/LocationModel';
import {
  checkCompany,
  filterByCompany,
  desc,
} from '../libs/utils';

export async function getDevice ({ id }) {
  const whereConditions = { id };
  const result = await DeviceModel.findOne({
    where: whereConditions,
    attributes: ['id', 'device_id', 'device_model', 'company_id', 'company_token'],
    raw: true,
  });
  return result;
}

export async function getDevices (params) {
  const whereConditions = {};
  if (filterByCompany) {
    params.company_id && (whereConditions.company_id = +params.company_id);
  }
  const result = await DeviceModel.findAll({
    where: whereConditions,
    attributes: ['id', 'device_id', 'device_model', 'company_id', 'company_token', 'framework'],
    order: [['updated_at', desc], ['created_at', desc]],
    raw: true,
  });
  return result;
}

export async function deleteDevice ({
  id: deviceId,
  start_date: startDate,
  end_date: endDate,
}) {
  const whereByDevice = {
    device_id: deviceId,
  };
  const where = { ...whereByDevice };
  if (startDate && endDate && new Date(startDate) && new Date(endDate)) {
    where.recorded_at = { [Op.between]: [new Date(startDate), new Date(endDate)] };
  }
  const result = await LocationModel.destroy({ where });
  const locationsCount = await LocationModel.count({ where: whereByDevice });
  if (!locationsCount) {
    await DeviceModel.destroy({
      where: {
        id: deviceId,
      },
      cascade: true,
    });
  }
  return result;
}

export const findOrCreate = async (
  org = {company_token: 'UNKNOWN'}, {
    model,
    uuid,
    framework,
    version,
  }
) => {
  const device = {
    device_id: uuid || 'UNKNOWN',
    model: model || 'UNKNOWN',
  };
  const now = new Date();

  checkCompany({ org: org.company_token, model: device.model });
  const company = await findOrCreateCompany(org);
  const where = { company_id: company.id };

  uuid && (where.device_id = uuid);

  const [row] = await DeviceModel.findOrCreate({
    where,
    defaults: {
      company_id: company.id,
      company_token: org.company_token,
      device_id: device.device_id,
      device_model: device.model,
      created_at: now,
      framework,
      version,
    },
    raw: true,
  });

  return row;
};
