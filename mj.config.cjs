/** @type {import('@memberjunction/config').MJConfig} */
module.exports = {
  entityPackageName: '@mj-biz-apps/tasks-entities',

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

  newEntityDefaults: {
    NameRulesBySchema: [
      { SchemaName: '${mj_core_schema}', EntityNamePrefix: 'MJ: ' },
      {
        SchemaName: '__mj_BizAppsTasks',
        EntityNamePrefix: 'MJ.BizApps.Tasks:',
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
