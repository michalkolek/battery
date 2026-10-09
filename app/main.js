const { app } = require( 'electron' )
const { alert } = require( './modules/helpers' )
const { set_initial_interface } = require( './modules/interface' )

// OFFLINE FORK: the 'update-electron-app' auto-updater was removed here so the
// GUI never contacts GitHub releases in the background. Update via the repo instead.

/* ///////////////////////////////
// Event listeners
// /////////////////////////////*/

app.whenReady().then( set_initial_interface )

/* ///////////////////////////////
// Global config
// /////////////////////////////*/

// Hide dock entry
app.dock.hide()

/* ///////////////////////////////
// Debugging
// /////////////////////////////*/
const debug = false
if( debug ) app.whenReady().then( async () => {

    await alert( __dirname )

    await alert( Object.keys( process.env ).join( '\n' ) )

    const { HOME, PATH, USER } = process.env
    await alert( `HOME: ${ HOME }\n\nPATH: ${ PATH }\n\nUSER: ${ USER }` )

} )
