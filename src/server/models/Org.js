import { isAdmin, desc } from '../libs/utils';
import CompanyModel from '../database/CompanyModel';

export async function getOrgs ({ company_token: org }) {

  const whereConditions = isAdmin(org) ? {} : { company_token: org };
  const result = await CompanyModel.findAll({
    where: whereConditions,
    order: [['updated_at', desc]],
    raw: true,
  });
  return result;
}

export async function findOrCreate (companyObj) {
  const now = new Date();
  const [company] = await CompanyModel.findOrCreate({
    where: { company_token: companyObj.company_token },
    defaults: { created_at: now, updated_at: now, ...companyObj },
    raw: true,
  });
  return company;
}
