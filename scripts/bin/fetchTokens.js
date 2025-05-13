#!/usr/bin/env node
import { RpcProvider, Contract } from 'starknet';
import dotenv from 'dotenv';
import fs from 'fs';
dotenv.config();

// constants
import manifest from '../../client/src/dojo/generated/mainnet/manifest.json' with {type: "json"};
const contractAddress = '0x07d8ea58612a5de25f29281199a4fc1f2ce42f0f207f93c3a35280605f3b8e68';

// Get abi from manifest
const abi = manifest.contracts.reduce((acc, c) => {
  return acc ?? (c.tag === 'karat-karat_token' ? c.abi : null);
}, null);

// create provider + contract
const provider = new RpcProvider({ nodeUrl: process.env.RPC_URL });
const contract = new Contract(abi, contractAddress, provider);

const supply = Number(await contract.total_supply());

console.log(`--- Fetching ${supply} tokens...`);
for (let i = 1; i <= supply; i++) {
  const { uri, svg, encoded, id } = await _getTokenUri(i);
  // validate
  if (encoded.indexOf(' ') !== -1) {
    console.log(`>>> invalid svg[${id}]:`, encoded);
    exit(1);
  }
  console.log(`token_uri[${id}]: OK!`);
}


async function _getTokenUri(i) {
  const id = `00${i}`.slice(-3);
  const jsonPath = `../tokens/${id}.json`;
  const svgPath = `../tokens/${id}.svg`;
  let uri;
  let svg;
  //
  // get uri...
  try {
    uri = fs.readFileSync(jsonPath, 'utf8');
    console.log(`file::uri[${id}]: ${jsonPath}`);
  } catch {
    uri = await contract.token_uri(i);
    uri = uri.replace('data:application/json,', '');
    fs.writeFileSync(jsonPath, uri);
    console.log(`token_uri[${id}]: ${jsonPath}`);
    await _wait(500);
  }
  //
  // get encoded svg...
  const data = JSON.parse(uri);
  const encoded = data.image.replace('data:image/svg+xml;base64,', '');
  //
  // get svg...
  try {
    svg = fs.readFileSync(svgPath, 'utf8');
    console.log(`file::SVG[${id}]: ${svgPath}`);
  } catch {
    const svg = Buffer.from(encoded, 'base64').toString('utf8');
    fs.writeFileSync(svgPath, svg);
    console.log(`token_uri[${id}]: ${svgPath}`);
  }
  return { uri, svg, encoded, id };
}

async function _wait(ms) {
  return new Promise(res => setTimeout(res, ms));
}
