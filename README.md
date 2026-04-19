# CloudX28 (Connect IQ)

Aplicación **Connect IQ** para relojes Garmin que permite **controlar alarmas X28** (consultar estado y enviar órdenes de activación/desactivación) desde la muñeca, usando la API de CloudX28.

## Requisito previo: Mi Alarma

La alarma debe estar **dada de alta y configurada previamente** con la app móvil **Mi Alarma** de X28. Esta app de reloj no sustituye ese paso; solo se conecta a tu cuenta ya existente.

- **Mi Alarma (Google Play):** https://play.google.com/store/apps/details?id=com.x28app&hl=es

En el reloj necesitarás las mismas credenciales (correo, contraseña y PIN) que uses con el servicio X28.

## Requisitos de desarrollo

1. **Garmin Connect IQ SDK** (incluye `monkeyc`, simulador y `monkeydo`). Descarga e instalación:
   - [Connect IQ SDK Manager / descargas](https://developer.garmin.com/connect-iq/sdk/)
2. Documentación útil:
   - [Guía del programador Connect IQ](https://developer.garmin.com/connect-iq/programmers-guide/)
   - [Referencia de la API (Monkey C)](https://developer.garmin.com/connect-iq/api-docs/)
3. **Clave de firma** del desarrollador en formato **DER PKCS#8** (`private_key.der`). No la subas a repositorios públicos. Ejemplo con OpenSSL:

```bash
openssl genrsa -out private_key.pem 4096
openssl pkcs8 -topk8 -inform PEM -outform DER -in private_key.pem -out private_key.der -nocrypt
```

El proyecto ignora `private_key.der` y `private_key.pem` mediante `.gitignore`.

## Compilar

Por defecto el `Makefile` apunta a una ruta de SDK bajo `~/.Garmin/ConnectIQ/Sdks/...`. Puedes sobrescribirla:

```bash
export SDK=/ruta/al/connectiq-sdk-lin-...
make build
```

Compilar para el producto definido en `manifest.xml` (por defecto **fenix7spro**; cámbialo en el manifiesto si tu reloj es otro modelo compatible):

```bash
make build
```

Equivalente manual:

```bash
monkeyc -f monkey.jungle -o CloudX28.prg -y private_key.der -d fenix7spro -w
```

Otros ejemplos:

```bash
make DEVICE=otro_product_id build   # si añades más productos al manifiesto
```

## Simulador (Linux y otros)

1. Arranca el simulador (en una terminal apartada):

   ```bash
   make simulator
   ```

   o ejecuta `connectiq` desde el directorio `bin` del SDK.

2. Con el simulador en marcha, construye y carga la app:

   ```bash
   make run
   ```

`make run` compila y ejecuta `monkeydo` pasando el archivo **`CloudX28-settings.json`** al sistema de archivos virtual del simulador; en **Linux** esto evita el error *«No settings file found for this app»* al editar ajustes desde el menú del simulador. Si llamas a `monkeydo` a mano, usa el mismo `-a` que genera el `Makefile` (véase también el archivo `BUILD` del repositorio).

En el simulador, configura **correo, contraseña y PIN** en **Archivo → Editar almacenamiento persistente → Editar datos de Application.properties** (o el editor de ajustes que ofrezca tu versión del SDK). En el **teléfono** usa la ruta descrita en [Configurar la cuenta en el móvil](#configurar-la-cuenta-en-el-móvil).

**Nota:** En reloj real las peticiones HTTPS suelen salir vía **Garmin Connect Mobile**; en el simulador el tráfico sale desde el equipo anfitrión.

## Configurar la cuenta en el móvil

Para introducir **correo**, **contraseña** y **PIN** en el reloj (los mismos datos que en Mi Alarma / CloudX28), hazlo desde la app **Garmin Connect IQ** en el teléfono:

1. Abre **Garmin Connect IQ**.
2. Pulsa **More** (más / menú, según versión).
3. **Garmin Devices** → elige tu **reloj**.
4. Entra en **Activities & Applications** (actividades y aplicaciones).
5. Busca **CloudX28** en la lista y abre sus **ajustes** para editar las credenciales.

Los nombres exactos de los menús pueden cambiar según **idioma** o **versión** de la aplicación Garmin Connect IQ.

## Instalar en el reloj

1. Empareja el reloj con **Garmin Connect** y mantén el Bluetooth activo.
2. Genera `CloudX28.prg` firmado con tu clave (paso *Compilar*).
3. Instala la app (extensión **Garmin Connect IQ** para VS Code, herramientas del SDK, o publicación en la tienda Connect IQ según tu flujo).
4. Configura la cuenta en el móvil (sección anterior) y sincroniza para que los ajustes lleguen al reloj.
5. Abre **CloudX28** desde el menú de aplicaciones del reloj. Cuando los tres campos estén guardados, la app pasa sola a la vista principal tras un instante.

## Idiomas

El manifiesto declara **inglés** y **español**; las cadenas están en `resources/strings/strings.xml` (predeterminado) y `resources-spa/strings/strings.xml` (español), siguiendo el mecanismo estándar de recursos Connect IQ.

## Aviso legal (no oficial)

- Esta aplicación es un **proyecto independiente** desarrollado por terceros. **No es una aplicación oficial** de Garmin ni de X28 (ni de sus empresas asociadas).
- **Garmin**, **Connect IQ**, **Garmin Connect** y los nombres o logotipos relacionados son **marcas comerciales** de Garmin Ltd. o de sus filiales. Esta app **no está respaldada, patrocinada ni aprobada** por Garmin.
- **X28**, **Mi Alarma**, **CloudX28** y los servicios o marcas asociados pertenecen a sus respectivos titulares. Esta app **no está respaldada, patrocinada ni aprobada** por X28.
- El software se ofrece **«tal cual»**, **sin garantía** de ningún tipo (incluidos el funcionamiento ininterrumpido, la exactitud de los datos o la compatibilidad con todos los dispositivos o versiones del sistema). **El uso es bajo tu propia responsabilidad.**
- El autor o los colaboradores del repositorio **no asumen responsabilidad** por daños directos o indirectos, pérdida de datos, incumplimiento de servicios de terceros o conflictos con las condiciones de uso de Garmin, X28 u otros proveedores.
- Al usar la app debes cumplir las **condiciones de uso** y la **legislación aplicable** (incluidas las de Garmin Connect IQ, la tienda Connect IQ si publicas allí, y las del servicio X28 / API que utilices).

## Licencia y aviso técnico

Este repositorio es software de terceros pensado para integrarse con APIs y ecosistemas de Garmin/X28. Respeta las licencias del **SDK Connect IQ** de Garmin y las condiciones de uso de los servicios X28 y de cualquier otra plataforma que emplees para compilar o distribuir la aplicación.
