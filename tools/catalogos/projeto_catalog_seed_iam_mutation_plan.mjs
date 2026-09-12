import {
  SEED_IAM_AUTH_STRATEGY,
  SEED_IAM_CUSTOM_ROLE_ID,
  SEED_IAM_PROJECT_ID,
  SEED_IAM_REQUIRED_DATA_PERMISSIONS,
  SEED_IAM_SERVICE_ACCOUNT_ID,
} from './projeto_catalog_seed_iam_blueprint.mjs';

export const IAM_PLAN_MODE = 'dry-run-only';

export const IAM_PLAN_SERVICE_ACCOUNT_EMAIL =
  `${SEED_IAM_SERVICE_ACCOUNT_ID}` +
  `@${SEED_IAM_PROJECT_ID}.iam.gserviceaccount.com`;

export const IAM_PLAN_CUSTOM_ROLE_NAME =
  `projects/${SEED_IAM_PROJECT_ID}` +
  `/roles/${SEED_IAM_CUSTOM_ROLE_ID}`;

export const IAM_PLAN_TOKEN_CREATOR_ROLE =
  'roles/iam.serviceAccountTokenCreator';

function fail(code, details = null) {
  const error = new Error(code);

  if (details !== null) {
    error.details = details;
  }

  throw error;
}

function normalize(value) {
  return typeof value === 'string'
    ? value.trim()
    : '';
}

export function validateOperatorPrincipal(
  operatorPrincipal,
) {
  const value = normalize(operatorPrincipal);

  if (value === '') {
    fail('BUGRAE002E_IAM_PLAN_OPERATOR_PRINCIPAL_REQUIRED');
  }

  const allowedPrefixes = [
    'user:',
    'serviceAccount:',
    'group:',
  ];

  if (
    !allowedPrefixes.some(
      (prefix) => value.startsWith(prefix),
    )
  ) {
    fail('BUGRAE002E_IAM_PLAN_OPERATOR_PRINCIPAL_INVALID');
  }

  return value;
}

function operation({
  id,
  kind,
  description,
  command,
  mutatesIam = true,
}) {
  return Object.freeze({
    id,
    kind,
    description,
    command: Object.freeze([...command]),
    mutatesIam,
    execute: false,
  });
}

export function buildSeedIamMutationDryRun({
  operatorPrincipal,
}) {
  const operator =
    validateOperatorPrincipal(
      operatorPrincipal,
    );

  const permissions =
    SEED_IAM_REQUIRED_DATA_PERMISSIONS.join(',');

  const serviceAccountMember =
    `serviceAccount:${IAM_PLAN_SERVICE_ACCOUNT_EMAIL}`;

  const forward = Object.freeze([
    operation({
      id: 'create-service-account',
      kind: 'CREATE_SERVICE_ACCOUNT',
      description:
        'Criar identidade tecnica dedicada ao seed do catalogo.',
      command: [
        'gcloud',
        'iam',
        'service-accounts',
        'create',
        SEED_IAM_SERVICE_ACCOUNT_ID,
        `--project=${SEED_IAM_PROJECT_ID}`,
        '--display-name=Fenix Project Catalog Seed',
        '--description=Identidade dedicada ao seed CREATE_ONLY do catalogo institucional de projetos',
      ],
    }),

    operation({
      id: 'create-custom-role',
      kind: 'CREATE_CUSTOM_ROLE',
      description:
        'Criar custom role apenas com datastore.entities.get e datastore.entities.create.',
      command: [
        'gcloud',
        'iam',
        'roles',
        'create',
        SEED_IAM_CUSTOM_ROLE_ID,
        `--project=${SEED_IAM_PROJECT_ID}`,
        '--title=Fenix Project Catalog Seed Create Only',
        '--description=Least privilege para GET conhecido e CREATE_ONLY do catalogo institucional',
        `--permissions=${permissions}`,
        '--stage=GA',
      ],
    }),

    operation({
      id: 'bind-custom-role-to-seed-service-account',
      kind: 'ADD_PROJECT_IAM_BINDING',
      description:
        'Conceder a custom role somente a service account dedicada.',
      command: [
        'gcloud',
        'projects',
        'add-iam-policy-binding',
        SEED_IAM_PROJECT_ID,
        `--member=${serviceAccountMember}`,
        `--role=${IAM_PLAN_CUSTOM_ROLE_NAME}`,
        '--condition=None',
      ],
    }),

    operation({
      id: 'bind-token-creator-on-target-service-account',
      kind: 'ADD_SERVICE_ACCOUNT_IAM_BINDING',
      description:
        'Permitir ao operador obter token curto apenas da service account alvo.',
      command: [
        'gcloud',
        'iam',
        'service-accounts',
        'add-iam-policy-binding',
        IAM_PLAN_SERVICE_ACCOUNT_EMAIL,
        `--project=${SEED_IAM_PROJECT_ID}`,
        `--member=${operator}`,
        `--role=${IAM_PLAN_TOKEN_CREATOR_ROLE}`,
      ],
    }),
  ]);

  const rollback = Object.freeze([
    operation({
      id: 'rollback-token-creator-binding',
      kind: 'REMOVE_SERVICE_ACCOUNT_IAM_BINDING',
      description:
        'Remover o direito de impersonacao da service account alvo.',
      command: [
        'gcloud',
        'iam',
        'service-accounts',
        'remove-iam-policy-binding',
        IAM_PLAN_SERVICE_ACCOUNT_EMAIL,
        `--project=${SEED_IAM_PROJECT_ID}`,
        `--member=${operator}`,
        `--role=${IAM_PLAN_TOKEN_CREATOR_ROLE}`,
      ],
    }),

    operation({
      id: 'rollback-project-role-binding',
      kind: 'REMOVE_PROJECT_IAM_BINDING',
      description:
        'Remover da service account a custom role do projeto.',
      command: [
        'gcloud',
        'projects',
        'remove-iam-policy-binding',
        SEED_IAM_PROJECT_ID,
        `--member=${serviceAccountMember}`,
        `--role=${IAM_PLAN_CUSTOM_ROLE_NAME}`,
        '--condition=None',
      ],
    }),

    operation({
      id: 'rollback-custom-role',
      kind: 'DELETE_CUSTOM_ROLE',
      description:
        'Excluir a custom role se continuar exclusiva desta intervencao.',
      command: [
        'gcloud',
        'iam',
        'roles',
        'delete',
        SEED_IAM_CUSTOM_ROLE_ID,
        `--project=${SEED_IAM_PROJECT_ID}`,
        '--quiet',
      ],
    }),

    operation({
      id: 'rollback-service-account',
      kind: 'DELETE_SERVICE_ACCOUNT',
      description:
        'Excluir a service account se continuar sem dependencia aprovada.',
      command: [
        'gcloud',
        'iam',
        'service-accounts',
        'delete',
        IAM_PLAN_SERVICE_ACCOUNT_EMAIL,
        `--project=${SEED_IAM_PROJECT_ID}`,
        '--quiet',
      ],
    }),
  ]);

  return Object.freeze({
    mode: IAM_PLAN_MODE,
    projectId: SEED_IAM_PROJECT_ID,
    authStrategy: SEED_IAM_AUTH_STRATEGY,
    operatorPrincipal: operator,
    serviceAccountId:
      SEED_IAM_SERVICE_ACCOUNT_ID,
    serviceAccountEmail:
      IAM_PLAN_SERVICE_ACCOUNT_EMAIL,
    customRoleId:
      SEED_IAM_CUSTOM_ROLE_ID,
    customRoleName:
      IAM_PLAN_CUSTOM_ROLE_NAME,
    customRolePermissions:
      SEED_IAM_REQUIRED_DATA_PERMISSIONS,
    persistentKeyAllowed: false,
    executeAvailable: false,
    remoteMutationPerformed: false,
    forward,
    rollback,
  });
}
