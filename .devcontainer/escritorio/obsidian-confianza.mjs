// La bóveda Notas, de confianza desde el primer arranque. Obsidian apunta en su
// localStorage, «enable-plugin-» más el id de la bóveda (el de obsidian.json), si se
// confió en ella: "true" carga sus plugins; sin la clave, abre el diálogo «¿Confías en el
// autor de esta bóveda?» y los deja apagados. Esto escribe ese localStorage, el LevelDB
// de Chromium en ~/.config/obsidian/Local Storage/leveldb, con las claves como las deja
// Obsidian: el origen, un 0, un 1 (texto en Latin-1) y la clave; el valor, un 1 y "true".
//   node obsidian-confianza.mjs CARPETA-DEL-LEVELDB ID-DE-LA-BOVEDA
import { ClassicLevel } from 'classic-level'

const [carpeta, id] = process.argv.slice(2)
const origen = 'app://obsidian.md'
const latin1 = (s) => Buffer.from(s, 'latin1')
const varint = (n) => { const b = []; for (n = BigInt(n); n > 127n; n >>= 7n) b.push(Number(n & 127n) | 128); b.push(Number(n)); return b }

const clave = latin1(`_${origen}\x00\x01enable-plugin-${id}`)
const valor = latin1('\x01true')
// Los metadatos del origen, como Chromium: la última modificación (microsegundos desde 1601)
// y lo que ocupa, en un protobuf de dos campos.
const ahora = BigInt(Date.now()) * 1000n + 11644473600000000n
const meta = Buffer.from([0x08, ...varint(ahora), 0x10, ...varint(clave.length + valor.length)])

const db = new ClassicLevel(carpeta, { keyEncoding: 'buffer', valueEncoding: 'buffer' })
await db.batch([
  { type: 'put', key: latin1('VERSION'), value: latin1('1') },
  { type: 'put', key: latin1(`META:${origen}`), value: meta },
  { type: 'put', key: clave, value: valor },
])
await db.close()
