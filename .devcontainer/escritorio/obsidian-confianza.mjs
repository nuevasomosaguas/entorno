// La bóveda Notas, de confianza desde el primer arranque. Obsidian apunta en su
// localStorage, «enable-plugin-» más el id de la bóveda (el de obsidian.json), si se
// confió en ella: "true" carga sus plugins; sin la clave, abre el diálogo «¿Confías en el
// autor de esta bóveda?» y los deja apagados. Esto escribe ese localStorage, el LevelDB
// de Chromium en ~/.config/obsidian/Local Storage/leveldb, con las claves como las deja
// Obsidian: el origen, un 0, un 1 (texto en Latin-1) y la clave; el valor, un 1 y "true".
// En el mismo localStorage, Templater guarda, por equipo y no en la bóveda, si aplica las
// plantillas de carpeta al crear una nota (las de Lecturas): se deja encendido.
//   node obsidian-confianza.mjs CARPETA-DEL-LEVELDB ID-DE-LA-BOVEDA
import { ClassicLevel } from 'classic-level'

const [carpeta, id] = process.argv.slice(2)
const origen = 'app://obsidian.md'
const latin1 = (s) => Buffer.from(s, 'latin1')
const varint = (n) => { const b = []; for (n = BigInt(n); n > 127n; n >>= 7n) b.push(Number(n & 127n) | 128); b.push(Number(n)); return b }

const claves = [
  [`enable-plugin-${id}`, 'true'],
  [`${id}-templater-local-settings`, '{"trigger_on_file_creation":true}'],
].map(([k, v]) => ({ type: 'put', key: latin1(`_${origen}\x00\x01${k}`), value: latin1(`\x01${v}`) }))
// Los metadatos del origen, como Chromium: la última modificación (microsegundos desde 1601)
// y lo que ocupa, en un protobuf de dos campos.
const ahora = BigInt(Date.now()) * 1000n + 11644473600000000n
const ocupa = claves.reduce((n, c) => n + c.key.length + c.value.length, 0)
const meta = Buffer.from([0x08, ...varint(ahora), 0x10, ...varint(ocupa)])

const db = new ClassicLevel(carpeta, { keyEncoding: 'buffer', valueEncoding: 'buffer' })
await db.batch([
  { type: 'put', key: latin1('VERSION'), value: latin1('1') },
  { type: 'put', key: latin1(`META:${origen}`), value: meta },
  ...claves,
])
await db.close()
