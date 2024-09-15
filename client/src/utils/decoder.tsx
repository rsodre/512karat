// import { decodeIpfsUrl } from '@/hooks/web3/IpfsHook'
import { Buffer } from 'buffer';

export function decodeMetadata(encodedMetadata: string) {
  let metadata = null;	// the metadata, decoded if base64
  let json: any = {};				// decoded, as a json object
  let image = null;			// image field, encoded, if present
  let animation = null;	// ani9mation field, encoded, if present
  if (typeof (encodedMetadata) == 'string') {
    metadata = decodeMimeData(encodedMetadata); // decode, IF base64, else copy
    try {
      try {
        json = JSON.parse(decodeMimeData(metadata));
      } catch (e) {
        console.error(`decodeMetadata() error:`, e);
        console.error(`decodeMetadata() metadata:`, metadata);
        throw e;
      }
      image = json.image ?? json.image_url ?? null;
      // image = decodeMediaUrl(image);
      // animation = json.animation_url ? decodeMediaUrl(json.animation_url) : null;
      Object.keys(json).forEach(key => {
        if (typeof json[key] == 'string') {
          json[key] = decodeMimeData(json[key]);
        }
      });
      metadata = JSON.stringify(json);
    } catch (error) {
      console.error(`decodeMetadata() error:`, error);
    }
  }
  return {
    metadata,		// json string
    json,				// json object
    image,			// original (url or encoded), good for using as src
    animation,	// original (url or encoded), good for using as src
  };
}

export function decodeMimeData(data: string): string {
  let mimeType = null;
  let mimeData = data;
  if (typeof (data) == 'string' && data.startsWith('data:')) {
    const dataParts = data.slice(5).split(';');
    mimeType = dataParts[0];
    mimeData = dataParts[1];
    if (mimeData.startsWith('base64,')) {
      if (mimeType == 'application/octet-stream') {
        // mimeData = [...decodeBase64Buffer(mimeData.slice(7))];
      } else {
        // mimeData = atob(mimeData.slice(7)); // deprecated
        mimeData = decodeBase64(mimeData.slice(7));
      }
    }
  }
  return mimeData;
}

export function decodeMediaUrl(url: string) {
  // return decodeIpfsUrl(url) ?? url;
  return url;
}


//-----------------------------------
// Base64
//
export function decodeBase64(data: string) {
  return Buffer.from(data, 'base64').toString('utf8');
}
export function decodeBase64Buffer(data: string) {
  return Buffer.from(data, 'base64');
}

// const encodeBase64Options = {
//   svg: false,
// }
// export function encodeBase64(data, options = null) {
//   let result = null;
//   if (data) {
//     result = '';
//     if (options) {
//       options = {
//         ...encodeBase64Options,
//         ...options,
//       }
//       if (options.svg) {
//         result += 'data:image/svg+xml;base64,';
//       } else if (options.html) {
//         result += 'data:text/html;base64,';
//       }
//     }
//     result += Buffer.from(data).toString('base64');
//   }
//   return result;
// }



