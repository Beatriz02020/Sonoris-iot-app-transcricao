# Cloud Function para Deletar Imagens Antigas do Cloudinary

## Por que usar Cloud Function?
- **Segurança**: API Secret fica no servidor, não no app
- **Confiável**: Executa automaticamente quando a foto muda
- **Gratuito**: Firebase Free Tier é suficiente

## Passo a Passo

### 1. Instalar Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

### 2. Inicializar Functions no seu projeto
```bash
cd c:\Users\biatr\Downloads\Sonoris-iot-app-transcricao
firebase init functions
```

### 3. Criar função `functions/index.js`:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');
const axios = require('axios');

admin.initializeApp();

// Configurar credenciais do Cloudinary nas Environment Variables:
// firebase functions:config:set cloudinary.cloud_name="dqliwz988"
// firebase functions:config:set cloudinary.api_key="SUA_API_KEY"
// firebase functions:config:set cloudinary.api_secret="SEU_API_SECRET"

// Função que escuta mudanças no campo Foto_url
exports.deleteOldProfilePhoto = functions.firestore
  .document('Usuario/{userId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    
    // Verifica se a foto mudou
    if (before.Foto_url === after.Foto_url) {
      return null;
    }
    
    const oldPhotoUrl = before.Foto_url;
    
    if (!oldPhotoUrl || oldPhotoUrl === '') {
      console.log('Nenhuma foto antiga para deletar');
      return null;
    }
    
    try {
      // Extrai publicId da URL antiga
      const publicId = extractPublicId(oldPhotoUrl, 'user_photos');
      
      if (!publicId) {
        console.error('Não foi possível extrair publicId:', oldPhotoUrl);
        return null;
      }
      
      console.log('Deletando foto antiga:', publicId);
      
      // Deleta do Cloudinary
      await deleteFromCloudinary(publicId);
      
      console.log('Foto antiga deletada com sucesso!');
      return null;
    } catch (error) {
      console.error('Erro ao deletar foto antiga:', error);
      return null;
    }
  });

// Função para deletar banner
exports.deleteOldBanner = functions.firestore
  .document('Usuario/{userId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    
    if (before.banner_url === after.banner_url) {
      return null;
    }
    
    const oldBannerUrl = before.banner_url;
    
    if (!oldBannerUrl || oldBannerUrl === '') {
      return null;
    }
    
    try {
      const publicId = extractPublicId(oldBannerUrl, 'user_banners');
      
      if (!publicId) {
        console.error('Não foi possível extrair publicId:', oldBannerUrl);
        return null;
      }
      
      console.log('Deletando banner antigo:', publicId);
      await deleteFromCloudinary(publicId);
      console.log('Banner antigo deletado com sucesso!');
      return null;
    } catch (error) {
      console.error('Erro ao deletar banner antigo:', error);
      return null;
    }
  });

// Helper: extrai publicId da URL
function extractPublicId(url, folder) {
  try {
    const cleanUrl = url.split('?')[0];
    const folderIndex = cleanUrl.indexOf(`/${folder}/`);
    if (folderIndex === -1) return null;
    
    const afterFolder = cleanUrl.substring(folderIndex + 1);
    const withoutExtension = afterFolder.split('.')[0];
    
    return withoutExtension;
  } catch (e) {
    console.error('Erro ao extrair publicId:', e);
    return null;
  }
}

// Helper: deleta do Cloudinary usando Admin API
async function deleteFromCloudinary(publicId) {
  const config = functions.config();
  const cloudName = config.cloudinary.cloud_name;
  const apiKey = config.cloudinary.api_key;
  const apiSecret = config.cloudinary.api_secret;
  
  const timestamp = Math.round(Date.now() / 1000);
  
  // Gera assinatura
  const stringToSign = `public_id=${publicId}&timestamp=${timestamp}${apiSecret}`;
  const signature = crypto.createHash('sha256').update(stringToSign).digest('hex');
  
  // Faz requisição
  const url = `https://api.cloudinary.com/v1_1/${cloudName}/image/destroy`;
  
  const response = await axios.post(url, {
    public_id: publicId,
    signature: signature,
    api_key: apiKey,
    timestamp: timestamp.toString(),
  });
  
  return response.data;
}
```

### 4. Instalar dependências
```bash
cd functions
npm install axios
```

### 5. Configurar variáveis de ambiente
```bash
firebase functions:config:set cloudinary.cloud_name="dqliwz988"
firebase functions:config:set cloudinary.api_key="SUA_API_KEY"
firebase functions:config:set cloudinary.api_secret="SEU_API_SECRET"
```

### 6. Deploy
```bash
firebase deploy --only functions
```

## Como funciona:
1. Usuário troca a foto no app
2. App faz upload da nova foto para Cloudinary
3. App atualiza `Foto_url` no Firestore
4. Cloud Function detecta a mudança
5. Cloud Function deleta automaticamente a foto antiga do Cloudinary

## Vantagens:
- ✅ API Secret seguro no servidor
- ✅ Automático (não precisa lembrar de deletar)
- ✅ Não adiciona complexidade no app
- ✅ Funciona mesmo se o app estiver fechado
