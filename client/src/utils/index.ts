import { Buffer } from 'buffer';

export function decodeBase64(data: string) {
  return Buffer.from(data ?? '', 'base64').toString('utf8');
}

export function decodeBase64Buffer(data: string) {
  return Buffer.from(data ?? '', 'base64');
}
