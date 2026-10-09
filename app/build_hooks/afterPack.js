/* ///////////////////////////////
// afterPack hook
// /////////////////////////////*/
//
// macOS 15 (Sequoia) refuses to run the freshly built app because local builds
// are not signed with a Developer ID certificate (the kernel's AMFI kills it
// with an "app is damaged" error). This hook re-signs the bundle ad-hoc after
// every build so it runs on your own Mac. It is NOT enough to distribute to
// other machines — for that you need a real certificate + notarisation.
//
// Registered in package.json: build.afterPack

const { execSync } = require( 'child_process' )
const log = ( ...messages ) => console.log( ...messages )

exports.default = async function afterPack( context ) {

    if ( context.packager.platform.name !== 'mac' ) return

    const { appOutDir } = context
    const appName = context.packager.appInfo.productFilename
    const appPath = `${ appOutDir }/${ appName }.app`

    const fs = require( 'fs' )
    if ( !fs.existsSync( appPath ) ) return

    log( `\n\n🪝 afterPack hook: ad-hoc re-signing ${ appName }.app` )

    // The app must live in a directory where macOS lets us clear its
    // provenance attributes: copy to a temp folder, clean, sign, copy back.
    const tmp = execSync( 'mktemp -d' ).toString().trim()
    const tmpApp = `${ tmp }/${ appName }.app`

    try {
        execSync( `cp -R "${ appPath }" "${ tmpApp }"` )
        execSync( `rm -rf "${ appPath }"` )
        execSync( `xattr -cr "${ tmpApp }"` )
        execSync( `codesign --force --deep --sign - "${ tmpApp }"`, { stdio: 'inherit' } )
        execSync( `mv "${ tmpApp }" "${ appPath }"` )
        log( `✅ Ad-hoc signature applied to ${ appPath }` )
    } catch ( e ) {
        log( `❌ afterPack re-signing failed: ${ e.message }` )
        throw e
    } finally {
        execSync( `rm -rf "${ tmp }"` )
    }

}
