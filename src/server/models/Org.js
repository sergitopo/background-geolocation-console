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

export async function update (companyObj) {
  const now = new Date();
  companyObj.company_token = companyObj.org;
  delete companyObj.org;
  companyObj.updated_at = new Date();
  const fields = Object.keys(companyObj);
  const company = await CompanyModel.update(companyObj, {
    where: { company_token: companyObj.company_token },
    fields,
    raw: true,
  });
  return company;
}
