import { createApp } from './app';
import { connectDb } from './config/db';
import { env } from './config/env';

async function bootstrap() {
  await connectDb();
  const app = createApp();
  app.listen(env.PORT, () => {
    console.log(`[api] listening on :${env.PORT} (${env.NODE_ENV})`);
  });
}

bootstrap().catch((err) => {
  console.error('[api] failed to start', err);
  process.exit(1);
});
