import { spawn } from 'node:child_process';

export const ADC_MIN_TOKEN_LENGTH = 50;

export function buildGcloudAdcInvocation({
  platform = process.platform,
  comSpec = process.env.ComSpec,
} = {}) {
  const adcArgs = [
    'auth',
    'application-default',
    'print-access-token',
    '--quiet',
  ];

  if (platform === 'win32') {
    return {
      command: comSpec || 'cmd.exe',
      args: ['/d', '/s', '/c', 'gcloud.cmd', ...adcArgs],
    };
  }

  return {
    command: 'gcloud',
    args: adcArgs,
  };
}

export async function defaultCommandRunner({ command, args }) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      shell: false,
      windowsHide: true,
      stdio: ['ignore', 'pipe', 'pipe'],
    });

    let stdout = '';
    let stderr = '';

    child.stdout.setEncoding('utf8');
    child.stderr.setEncoding('utf8');

    child.stdout.on('data', (chunk) => {
      stdout += chunk;
    });

    child.stderr.on('data', (chunk) => {
      stderr += chunk;
    });

    child.on('error', () => {
      reject(new Error('MIG001E4_ADC_PROCESS_START_FAILED'));
    });

    child.on('close', (code) => {
      resolve({
        code: Number.isInteger(code) ? code : -1,
        stdout,
        stderr,
      });
    });
  });
}

export function validateAccessToken(stdout) {
  const token = typeof stdout === 'string' ? stdout.trim() : '';

  if (
    token.length < ADC_MIN_TOKEN_LENGTH ||
    /\s/u.test(token)
  ) {
    throw new Error('MIG001E4_ADC_TOKEN_INVALID');
  }

  return token;
}

export function createGcloudAdcTokenProvider({
  runner = defaultCommandRunner,
  invocation = buildGcloudAdcInvocation(),
} = {}) {
  if (typeof runner !== 'function') {
    throw new Error('MIG001E4_ADC_RUNNER_REQUIRED');
  }

  return async function provideAccessToken() {
    const result = await runner({
      command: invocation.command,
      args: [...invocation.args],
    });

    if (!result || result.code !== 0) {
      throw new Error('MIG001E4_ADC_COMMAND_FAILED');
    }

    return validateAccessToken(result.stdout);
  };
}