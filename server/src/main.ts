import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { cors: true });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  const swaggerConfig = new DocumentBuilder()
    .setTitle('QuickSlot API')
    .setDescription(
      'Sports slot booking API. Concurrency-safe by Postgres partial unique index — exactly one confirmed booking can exist per (venue, slot_start_utc). Race losers get 409 SLOT_TAKEN.',
    )
    .setVersion('1.0')
    .addApiKey(
      { type: 'apiKey', in: 'header', name: 'X-User-Id' },
      'X-User-Id',
    )
    .addTag('Health')
    .addTag('Users')
    .addTag('Venues')
    .addTag('Bookings')
    .build();

  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('api/docs', app, document, {
    swaggerOptions: { persistAuthorization: true },
  });

  const config = app.get(ConfigService);
  const port = config.get<number>('PORT') ?? 3000;
  await app.listen(port);

  console.log(`QuickSlot API listening on :${port}`);
  console.log(`Swagger docs:           http://localhost:${port}/api/docs`);
}

void bootstrap();
