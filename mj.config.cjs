/** @type {import('@memberjunction/config').MJConfig} */
module.exports = {
  entityPackageName: '@mj-biz-apps/tasks-entities',

  testing: {
    checkModules: ['@mj-biz-apps/tasks-integration-tests'],
  },

  output: [
    { type: 'SQL', directory: './SQL Scripts/generated', appendOutputCode: true },
    { type: 'EntitySubclasses', directory: './packages/Entities/src/generated' },
    { type: 'ActionSubclasses', directory: './packages/Actions/src/generated' },
    { type: 'GraphQLServer', directory: './packages/Server/src/generated' },
    {
      type: 'Angular',
      directory: './packages/Angular/src/lib/generated',
      options: [{ name: 'maxComponentsPerModule', value: 20 }],
    },
    { type: 'DBSchemaJSON', directory: './Schema Files' },
  ],

  commands: [
    {
      workingDirectory: './packages/Entities',
      command: 'npm',
      args: ['run', 'build'],
      when: 'after',
    },
    {
      workingDirectory: './packages/Actions',
      command: 'npm',
      args: ['run', 'build'],
      when: 'after',
    },
  ],

  // Run CodeGen against MJ_BizAppTask (clean DB) — not MJ_5_9_0 which has Committees cross-schema FKs.
  //
  // Scope CodeGen to the schema tasks OWNS (__mj_BizAppsTasks). Exclude core (__mj)
  // and __mj_BizAppsCommon — tasks only references those via FK; they are owned by
  // MJ core and bizapps-common respectively and consumed as npm packages.
  // (Matches the bizapps-accounting convention; the codegen-lib defaults do NOT
  // exclude __mj_BizAppsCommon, so it must be listed explicitly.)
  excludeSchemas: ['sys', 'staging', 'dbo', '__mj', '__mj_BizAppsCommon', '__mj_BizAppsOrders', '__mj_BizAppsAccounting', '__mj_BizAppsIssues', '__mj_BizAppsMarketing', '__mj_BizAppsATS', '__mj_BizAppsCommittees', '__mj_BizAppsCaliber', '__mj_BizAppsForms'],

  // SQL output configuration with Flyway placeholders.
  // The app's own schema (__mj_BizAppsTasks) maps to ${flyway:defaultSchema} so it is
  // resolved at migrate time; core MJ uses the named ${mjSchema} placeholder.
  // __mj_BizAppsCommon is left literal (matches the bizapps-accounting convention).
  SQLOutput: {
    enabled: true,
    folderPath: './migrations/codegen/',
    appendToFile: false,
    convertCoreSchemaToFlywayMigrationFile: true,
    omitRecurringScriptsFromLog: false,
    schemaPlaceholders: [
      // Order matters: more-specific schemas must come first because
      // substitution is run sequentially with a greedy regex. If '__mj'
      // were listed first, it would also match the '__mj' prefix of
      // '__mj_BizAppsTasks', producing '${mjSchema}_BizAppsTasks'.
      { schema: '__mj_BizAppsTasks', placeholder: '${flyway:defaultSchema}' },
      { schema: '__mj', placeholder: '${mjSchema}' }
    ]
  },

  newEntityDefaults: {
    NameRulesBySchema: [
      { SchemaName: '${mj_core_schema}', EntityNamePrefix: 'MJ: ' },
      {
        SchemaName: '__mj_BizAppsTasks',
        EntityNamePrefix: 'MJ_BizApps_Tasks: ',
        EntityNameSuffix: '',
      }
    ]
  },

  dbHost: process.env.DB_HOST ?? 'localhost',
  dbPort: process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : 1433,
  dbDatabase: process.env.DB_DATABASE,
  dbUsername: process.env.DB_USERNAME,
  dbPassword: process.env.DB_PASSWORD,
  codeGenLogin: process.env.CODEGEN_DB_USERNAME,
  codeGenPassword: process.env.CODEGEN_DB_PASSWORD,
};
