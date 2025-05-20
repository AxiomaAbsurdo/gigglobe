module.exports = {
  title: 'Kestra PWA Workflow Orchestration',
  tagline: 'Documentation for integrating Kestra.io with a Progressive Web App for job matching workflows',
  url: 'https://your-domain.com',
  baseUrl: '/',
  favicon: 'img/favicon.ico',
  organizationName: 'your-organization',
  projectName: 'kestra-pwa-integration',
  themeConfig: {
    navbar: {
      title: 'Kestra PWA Integration',
      logo: {
        alt: 'Kestra PWA Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          to: 'docs/introduction',
          activeBasePath: 'docs',
          label: 'Documentation',
          position: 'left',
        },
        // {
        //   to: 'docs/workflows',
        //   activeBasePath: 'docs',
        //   label: 'Workflows',
        //   position: 'left',
        // },
        // {
        //   to: 'docs/api',
        //   activeBasePath: 'docs',
        //   label: 'API',
        //   position: 'left',
        // },
        {
          href: 'https://github.com/your-organization/kestra-pwa-integration',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Getting Started',
              to: 'docs/introduction',
            },
            // {
            //   label: 'Workflows',
            //   to: 'docs/workflows',
            // },
          ],
        },
        {
          title: 'Community',
          items: [
            {
              label: 'Stack Overflow',
              href: 'https://stackoverflow.com/questions/tagged/kestra',
            },
            {
              label: 'Discord',
              href: 'https://discord.gg/kestra',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'GitHub',
              href: 'https://github.com/your-organization/kestra-pwa-integration',
            },
            {
              label: 'Kestra Documentation',
              href: 'https://kestra.io/docs',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Your Project Name.`,
    },
    prism: {
      theme: require('prism-react-renderer/themes/github'),
      darkTheme: require('prism-react-renderer/themes/dracula'),
      additionalLanguages: ['yaml', 'bash', 'json'],
    },
    algolia: {
      // If you want to add search functionality
      apiKey: 'YOUR_API_KEY',
      indexName: 'kestra-pwa',
    },
  },
  presets: [
    [
      '@docusaurus/preset-classic',
      {
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          editUrl: 'https://github.com/your-organization/kestra-pwa-integration/edit/main/website/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      },
    ],
  ],
};
