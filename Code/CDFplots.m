clear all
sim = '20metros-8STAs';
traffic_type = 'Bursty';
traffic_load = 'low';

figure
load(horzcat('simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load', '/DCFdelay.mat'));
cdf1 = cdfplot(DCFdelay*1000);
set(cdf1(:,1), 'LineWidth', 2, 'color', [0.7020    0.5059    0.5059]);
clear DCFdelay
clear cdf1
hold on

load(horzcat('simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load', '/CSRNumPkdelay.mat'));
cdf2 = cdfplot(CSRNumPkdelay*1000);
set(cdf2(:,1), 'LineWidth', 2, 'color', [0.5059    0.6235    0.7020]);
clear CSRNumPkdelay
clear cdf2
hold on

load(horzcat('simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load', '/CSROldPkdelay.mat'));
cdf3 = cdfplot(CSROldPkdelay*1000);
set(cdf3(:,1), 'LineWidth', 2, 'color', [0.3686    0.2745    0.2745]);
clear CSROldPkdelay
clear cdf3
hold on

load(horzcat('simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load', '/CSRWeighteddelay.mat'));
cdf4 = cdfplot(CSRWeighteddelay*1000);
set(cdf4(:,1), 'LineWidth', 2, 'color', [0.7020    0.6980    0.5059]);
clear CSRWeighteddelay
clear cdf4

title('', 'interpreter','latex', 'FontSize', 14)
xlabel('Packet delay [ms]', 'interpreter','latex', 'FontSize', 14)
xlim([0 10])
ylabel('F(x)', 'interpreter','latex', 'FontSize', 14)
set(gca, 'TickLabelInterpreter','latex');
names = {'DCF' 'C-SR, NumPk' 'C-SR, OldPk', 'C-SR Weighted'};
legend(names, 'Interpreter','latex', 'location', 'southeast', 'Orientation', 'vertical'  , 'FontSize', 14)
grid on


