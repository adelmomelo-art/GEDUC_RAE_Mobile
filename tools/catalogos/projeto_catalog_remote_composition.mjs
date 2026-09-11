import {
  createGcloudAdcTokenProvider,
} from '../migration/mig001e4_adc.mjs';

import {
  FirestoreProjectCatalogCreateOnlyAdapter,
} from './projeto_catalog_firestore_create_only.mjs';

import {
  preflightCreateOnlyTargets,
} from './projeto_catalog_executor.mjs';

import {
  SEED_PROJECT_ID,
  executeDryRun,
} from './projeto_catalog_seed.mjs';

function fail(code, details = null) {
  const error = new Error(code);
  if (details !== null) error.details = details;
  throw error;
}

function normalize(value) {
  return typeof value === 'string' ? value.trim() : '';
}

export function assertCompositionProjectId(projectId) {
  if (normalize(projectId) !== SEED_PROJECT_ID) {
    fail('BUGRAE002E_COMPOSITION_PROJECT_CONFIRMATION_MISMATCH');
  }

  return SEED_PROJECT_ID;
}

export function memoizeAccessTokenProvider(provider) {
  if (typeof provider !== 'function') {
    fail('BUGRAE002E_COMPOSITION_TOKEN_PROVIDER_REQUIRED');
  }

  let tokenPromise = null;

  return async function provideMemoizedAccessToken() {
    if (tokenPromise === null) {
      tokenPromise = Promise.resolve().then(() => provider());
    }

    try {
      return await tokenPromise;
    } catch (error) {
      tokenPromise = null;
      throw error;
    }
  };
}

function createReadOnlyWriter(adapter) {
  return Object.freeze({
    getExistingContentHash:
      adapter.getExistingContentHash.bind(adapter),

    async createOnly() {
      fail('BUGRAE002E_COMPOSITION_REMOTE_WRITE_DISABLED');
    },
  });
}

export function createCatalogRemoteReadOnlyComposition({
  projectId,
  fetchFn,
  accessTokenProvider,
}) {
  assertCompositionProjectId(projectId);

  if (typeof fetchFn !== 'function') {
    fail('BUGRAE002E_COMPOSITION_FETCH_REQUIRED');
  }

  const memoizedAccessTokenProvider =
    memoizeAccessTokenProvider(accessTokenProvider);

  const adapter =
    new FirestoreProjectCatalogCreateOnlyAdapter({
      projectId,
      fetchFn,
      accessTokenProvider: memoizedAccessTokenProvider,
    });

  const readOnlyWriter =
    createReadOnlyWriter(adapter);

  async function runReadOnlyPreflight() {
    const local = await executeDryRun({
      projectId,
    });

    const preflight =
      await preflightCreateOnlyTargets({
        writer: readOnlyWriter,
        plan: local.plan,
      });

    return Object.freeze({
      mode: 'remote-read-only-composition',
      projectId,
      collection: 'projetos',
      expected: local.plan.length,
      ready: preflight.ready,
      checked: preflight.checked,
      missing: preflight.missing,
      unchanged: preflight.unchanged,
      blockers: preflight.blockers,
      remoteWriteEnabled: false,
      firestoreWrites: 0,
    });
  }

  return Object.freeze({
    runReadOnlyPreflight,
    remoteWriteEnabled: false,
  });
}

export function createProductionCatalogReadOnlyComposition({
  projectId,
  fetchFn = globalThis.fetch,
  adcTokenProviderFactory =
    createGcloudAdcTokenProvider,
} = {}) {
  assertCompositionProjectId(projectId);

  if (typeof fetchFn !== 'function') {
    fail('BUGRAE002E_COMPOSITION_FETCH_REQUIRED');
  }

  if (typeof adcTokenProviderFactory !== 'function') {
    fail('BUGRAE002E_COMPOSITION_ADC_FACTORY_REQUIRED');
  }

  const accessTokenProvider =
    adcTokenProviderFactory();

  if (typeof accessTokenProvider !== 'function') {
    fail('BUGRAE002E_COMPOSITION_ADC_PROVIDER_INVALID');
  }

  return createCatalogRemoteReadOnlyComposition({
    projectId,
    fetchFn,
    accessTokenProvider,
  });
}
