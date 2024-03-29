// import { GameDig } from 'gamedig';
// Or if you're using CommonJS:
const { GameDig } = require('gamedig'); 

GameDig.query({
    type: 'enshrouded',
    host: 'localhost'
}).then((state) => {
    console.log(state.numplayers);
}).catch((error) => {
    console.log(`Server is offline, error: ${error}`);
});