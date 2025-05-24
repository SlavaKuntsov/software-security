-- Создание таблицы ChatMessages, если она еще не существует
CREATE TABLE IF NOT EXISTS "ChatMessages" (
    "Id" TEXT NOT NULL,
    "SenderId" TEXT NOT NULL,
    "ReceiverId" TEXT NOT NULL,
    "Content" TEXT NOT NULL,
    "Timestamp" TIMESTAMP WITH TIME ZONE NOT NULL,
    "IsRead" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ChatMessages" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_ChatMessages_Users_SenderId" FOREIGN KEY ("SenderId") REFERENCES "Users" ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_ChatMessages_Users_ReceiverId" FOREIGN KEY ("ReceiverId") REFERENCES "Users" ("Id") ON DELETE RESTRICT
);

-- Создание индексов для ускорения запросов
CREATE INDEX IF NOT EXISTS "IX_ChatMessages_SenderId" ON "ChatMessages" ("SenderId");
CREATE INDEX IF NOT EXISTS "IX_ChatMessages_ReceiverId" ON "ChatMessages" ("ReceiverId");
CREATE INDEX IF NOT EXISTS "IX_ChatMessages_Timestamp" ON "ChatMessages" ("Timestamp");
CREATE INDEX IF NOT EXISTS "IX_ChatMessages_IsRead" ON "ChatMessages" ("IsRead");

-- Добавление записи в таблицу миграций
INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20250524013234_UpdateChatRelations', '8.0.3')
ON CONFLICT ("MigrationId") DO NOTHING; 