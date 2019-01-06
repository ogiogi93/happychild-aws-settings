local appId = std.extVar('appId');

local region = 'ap-northeast-1';
# local elbSecurityGroup = ['sg-016fb077dfde5c3dc']; # private
local elbSecurityGroup = ['sg-07616906134585910']; # public
local taskSecurityGroup = ['sg-0a40e5d4ba5c7ad61'];
local privateSubnets = ['subnet-05906a4574afa4df3', 'subnet-0871af97fc92a0721'];
local publicSubnets = ['subnet-00eda27c49f7f4838', 'subnet-03842aef47186f750'];

local provideFromFile(name) = std.native('provide.file')(std.toString({ path: 'secrets.env' }), name);

{
  scheduler: {
    type: 'ecs',
    region: region,
    cluster: 'holiday-visualizer-staging',
    desired_count: 1,
    task_role_arn: 'arn:aws:iam::842367937408:role/holidayVisualizerStagingRole',
    elb_v2: {
      vpc_id: 'vpc-0aa7f3b33f1e7c7a4',
      health_check_path: '/ping',
      listeners: [
        {
          port: 80,
          protocol: 'HTTP',
        },
        {
          port: 443,
          protocol: 'HTTPS',
          certificate_arn: 'arn:aws:acm:ap-northeast-1:842367937408:certificate/818681c0-6053-4978-acf4-608aa1a3ef9e',
        },
      ],
      subnets: publicSubnets,
      security_groups: elbSecurityGroup,
      load_balancer_attributes: {
        'access_logs.s3.enabled': 'true',
        'access_logs.s3.bucket': 'holiday-visualizer-hako-access-logs',
        'access_logs.s3.prefix': std.format('hako-%s', appId),
        'idle_timeout.timeout_seconds': '10',
      },
      target_group_attributes: {
        'deregistration_delay.timeout_seconds': '60',
      },
    },
    execution_role_arn:'arn:aws:iam::842367937408:role/ecsTaskExecutionRole',
    cpu: '1024',
    memory: '2048',
    requires_compatibilities: ['FARGATE'],
    network_mode: 'awsvpc',
    launch_type: 'FARGATE',
    network_configuration: {
      awsvpc_configuration: {
      subnets: privateSubnets,
      security_groups: taskSecurityGroup,
      assign_public_ip: 'ENABLED',
     },
   },
  },
  app: {
    image: '842367937408.dkr.ecr.ap-northeast-1.amazonaws.com/holiday-visualizer',
    memory_reservation: '1024',
    command: ["run_develop"],
    env: {
        ENV: 'STAGING',
        MYSQL_USER: 'root',
        MYSQL_HOST: 'holiday-visualization-staging-001.cnghgma2cgdu.ap-northeast-1.rds.amazonaws.com',
        MYSQL_DATABASE: 'holiday_visualization',
        MYSQL_PASSWORD: provideFromFile('mysql_password'),
        MYSQL_VISUALIZER_USER: 'root',
        MYSQL_VISUALIZER_HOST: 'holiday-visualization-staging-001.cnghgma2cgdu.ap-northeast-1.rds.amazonaws.com',
        MYSQL_VISUALIZER_DATABASE: 'holiday_visualization',
        MYSQL_VISUALIZER_PASSWORD: provideFromFile('mysql_password'),
        RESAS_API_KEY: 'I5Uzf632CsHe7MkAkxKAEE7bWxhjODO7qPa7K3Cj',
    },
    log_configuration: {
        log_driver: 'awslogs',
        options: {
            'awslogs-group': 'holiday-visualizer-staging',
            'awslogs-region': 'ap-northeast-1',
            'awslogs-stream-prefix': 'app',
        },
    },
  },
  sidecars: {
    front: {
      image_tag: '842367937408.dkr.ecr.ap-northeast-1.amazonaws.com/hako-nginx',
      memory: '64',
      cpu: '32',
      log_configuration: {
        log_driver: 'awslogs',
        options: {
            'awslogs-group': 'holiday-visualizer-staging',
            'awslogs-region': 'ap-northeast-1',
            'awslogs-stream-prefix': 'front',
        },
      },
    },
  },
  scripts: [
    (import 'front.libsonnet') + {
       backend_port: 8000,
    },
  ],
}
