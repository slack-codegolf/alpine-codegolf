'use strict';
const app = require('express')();
const bodyParser = require('body-parser');

// application
const fs = require('fs');
const cps = require('child_process');
const Puid = require('puid');

const puid = new Puid(true);

// express
app.set('port', (process.env.PORT || 3000));
app.use(bodyParser.json({limit: '10mb'}));

app.get('/', (req, res, next) => res.send('Hello World!'));
app.post('/', (req, res, next) => {
  const {inOuts, lang, code} = req.body;
  let success = false;

  if (!Array.isArray(inOuts) || typeof lang !== 'string' || typeof code !== 'string') {
    res.json({success, out: 'Invalid Request'});
    return;
  }

  const codeId = puid.generate();
  fs.mkdirSync(`input/${codeId}`);
  fs.mkdirSync(`answer/${codeId}`);
  fs.writeFileSync(`input/${codeId}/code`, code);

  for (let i = 1; i <= inOuts.length; i++) {
    const {input, output} = inOuts[Math.floor(Math.random() * inOuts.length)];
    fs.writeFileSync(`input/${codeId}/hole${i}`, input);
    fs.writeFileSync(`answer/${codeId}/hole${i}`, output);
  }

  const env = `LANG="${lang}" CODEID="${codeId}" `;
  const command = 'bash ./task.sh';

  try {
    cps.execSync(env + command, {timeout: 30 * 1000});
    success = true;
  } catch (e) {
  }
  const out = fs.readFileSync(`output/${codeId}`, 'utf8');
  cps.exec(`rm -rf ./input/${codeId} ./answer/${codeId} ./output/${codeId}`);

  res.json({success, out});
});

app.listen(app.get('port'), () => {
  console.log('Node app is running on port', app.get('port'));
});
