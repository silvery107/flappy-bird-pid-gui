classdef flappy_bird_controller_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        FlappyBirdControllerUIFigure  matlab.ui.Figure
        ControlModeSwitchLabel        matlab.ui.control.Label
        ControlModeSwitch             matlab.ui.control.Switch
        FlappyBirdLabel               matlab.ui.control.Label
        FlappyBirdSwitch              matlab.ui.control.Switch
        TrajectoryPlotSwitchLabel     matlab.ui.control.Label
        TrajectoryPlotSwitch          matlab.ui.control.Switch
        ClearTrajectoryButton         matlab.ui.control.Button
        GameRestartButton             matlab.ui.control.Button
        BoundarySettingPanel          matlab.ui.container.Panel
        XOffsetSpinnerLabel           matlab.ui.control.Label
        XOffsetSpinner                matlab.ui.control.Spinner
        YOffsetSpinnerLabel           matlab.ui.control.Label
        YOffsetSpinner                matlab.ui.control.Spinner
        PIDTuningPanel                matlab.ui.container.Panel
        KiSpinnerLabel                matlab.ui.control.Label
        KiSpinner                     matlab.ui.control.Spinner
        KpSpinnerLabel                matlab.ui.control.Label
        KpSpinner                     matlab.ui.control.Spinner
        KdSpinnerLabel                matlab.ui.control.Label
        KdSpinner                     matlab.ui.control.Spinner
        GameSpeedSliderLabel          matlab.ui.control.Label
        GameSpeedSlider               matlab.ui.control.Slider
        Lamp                          matlab.ui.control.Lamp
        FlappyBirdControllerLabel     matlab.ui.control.Label
        CheckBox                      matlab.ui.control.CheckBox
        UIAxes                        matlab.ui.control.UIAxes
    end

    
    properties (Access = private)

    end
    
    properties (Access = public)
        yOffset = 10;
        xOffset = 30;
        isStart = false;        % turn the Game on or off
        status = false;         % the bird's running time
        Kp = 1; 
        Ki = 0;
        Kd = 0;
        LastErr = 0;
        IntegralErr = 0;
        RestartKey = false;
        GameSpeed = 1;
        isSpeedChanged = true;
    end
    
    methods (Access = public)
        
        function initPID(app)
            app.LastErr = 0;
            app.IntegralErr = 0;
        end

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
        end

        % Value changed function: YOffsetSpinner
        function YOffsetSpinnerValueChanged(app, event)
            value = app.YOffsetSpinner.Value;
            app.yOffset=value;
        end

        % Value changed function: XOffsetSpinner
        function XOffsetSpinnerValueChanged(app, event)
            value = app.XOffsetSpinner.Value;
            app.xOffset = value;
        end

        % Value changed function: ControlModeSwitch
        function ControlModeSwitchValueChanged(app, event)
            value = app.ControlModeSwitch.Value;
            
        end

        % Value changed function: FlappyBirdSwitch
        function FlappyBirdSwitchValueChanged(app, event)
            app.status = ~app.status;
            if app.status
                app.Lamp.Color = [0,1,0];
                if ~app.isStart
                    flappybird_heuristic(app);
                end
            else
                app.Lamp.Color = [1,0,0];
%                 if app.isStart
%                     close('Flappy Bird 1.0','force');
%                 end
            end
        end

        % Close request function: FlappyBirdControllerUIFigure
        function FlappyBirdControllerUIFigureCloseRequest(app, event)
            if app.isStart == true
                app.isStart = false;
                close('Flappy Bird 1.0','force');
            end
            delete(app);
        end

        % Value changed function: TrajectoryPlotSwitch
        function TrajectoryPlotSwitchValueChanged(app, event)
            value = app.TrajectoryPlotSwitch.Value;
            
        end

        % Button pushed function: ClearTrajectoryButton
        function ClearTrajectoryButtonPushed(app, event)
            cla(app.UIAxes);
        end

        % Button pushed function: GameRestartButton
        function GameRestartButtonPushed(app, event)
            app.RestartKey = true;
            app.initPID();
        end

        % Value changed function: KpSpinner
        function KpSpinnerValueChanged(app, event)
            value = app.KpSpinner.Value;
            app.Kp = value;
        end

        % Value changed function: KdSpinner
        function KdSpinnerValueChanged(app, event)
            value = app.KdSpinner.Value;
            app.Kd = value;
        end

        % Value changed function: KiSpinner
        function KiSpinnerValueChanged(app, event)
            value = app.KiSpinner.Value;
            app.Ki = value;
        end

        % Value changed function: GameSpeedSlider
        function GameSpeedSliderValueChanged(app, event)
            app.GameSpeedSlider.Value = round(app.GameSpeedSlider.Value);
            app.GameSpeed = app.GameSpeedSlider.Value;
        end

        % Value changed function: CheckBox
        function CheckBoxValueChanged(app, event)
            value = app.CheckBox.Value;
            if value
                app.KpSpinner.Enable = true;
                app.KiSpinner.Enable = true;
                app.KdSpinner.Enable = true;
            else
                app.KpSpinner.Enable = false;
                app.KiSpinner.Enable = false;
                app.KdSpinner.Enable = false;  
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create FlappyBirdControllerUIFigure and hide until all components are created
            app.FlappyBirdControllerUIFigure = uifigure('Visible', 'off');
            app.FlappyBirdControllerUIFigure.Position = [400 100 450 512];
            app.FlappyBirdControllerUIFigure.Name = 'Flappy Bird Controller';
            app.FlappyBirdControllerUIFigure.CloseRequestFcn = createCallbackFcn(app, @FlappyBirdControllerUIFigureCloseRequest, true);

            % Create ControlModeSwitchLabel
            app.ControlModeSwitchLabel = uilabel(app.FlappyBirdControllerUIFigure);
            app.ControlModeSwitchLabel.HorizontalAlignment = 'center';
            app.ControlModeSwitchLabel.FontSize = 16;
            app.ControlModeSwitchLabel.FontWeight = 'bold';
            app.ControlModeSwitchLabel.Position = [172 437 108 22];
            app.ControlModeSwitchLabel.Text = 'Control Mode';

            % Create ControlModeSwitch
            app.ControlModeSwitch = uiswitch(app.FlappyBirdControllerUIFigure, 'slider');
            app.ControlModeSwitch.Items = {'Manual', 'Auto'};
            app.ControlModeSwitch.ItemsData = {'Manual', 'Auto'};
            app.ControlModeSwitch.ValueChangedFcn = createCallbackFcn(app, @ControlModeSwitchValueChanged, true);
            app.ControlModeSwitch.Position = [210 405 45 20];
            app.ControlModeSwitch.Value = 'Manual';

            % Create FlappyBirdLabel
            app.FlappyBirdLabel = uilabel(app.FlappyBirdControllerUIFigure);
            app.FlappyBirdLabel.HorizontalAlignment = 'center';
            app.FlappyBirdLabel.FontSize = 16;
            app.FlappyBirdLabel.FontWeight = 'bold';
            app.FlappyBirdLabel.Position = [40.5 437 94 22];
            app.FlappyBirdLabel.Text = 'Flappy Bird';

            % Create FlappyBirdSwitch
            app.FlappyBirdSwitch = uiswitch(app.FlappyBirdControllerUIFigure, 'slider');
            app.FlappyBirdSwitch.Items = {'Exit', 'Play'};
            app.FlappyBirdSwitch.ValueChangedFcn = createCallbackFcn(app, @FlappyBirdSwitchValueChanged, true);
            app.FlappyBirdSwitch.Position = [64 405 45 20];
            app.FlappyBirdSwitch.Value = 'Exit';

            % Create TrajectoryPlotSwitchLabel
            app.TrajectoryPlotSwitchLabel = uilabel(app.FlappyBirdControllerUIFigure);
            app.TrajectoryPlotSwitchLabel.HorizontalAlignment = 'center';
            app.TrajectoryPlotSwitchLabel.FontSize = 16;
            app.TrajectoryPlotSwitchLabel.FontWeight = 'bold';
            app.TrajectoryPlotSwitchLabel.Position = [313 437 116 22];
            app.TrajectoryPlotSwitchLabel.Text = 'Trajectory Plot';

            % Create TrajectoryPlotSwitch
            app.TrajectoryPlotSwitch = uiswitch(app.FlappyBirdControllerUIFigure, 'slider');
            app.TrajectoryPlotSwitch.ItemsData = {'Off', 'On'};
            app.TrajectoryPlotSwitch.ValueChangedFcn = createCallbackFcn(app, @TrajectoryPlotSwitchValueChanged, true);
            app.TrajectoryPlotSwitch.Position = [346 405 45 20];

            % Create ClearTrajectoryButton
            app.ClearTrajectoryButton = uibutton(app.FlappyBirdControllerUIFigure, 'push');
            app.ClearTrajectoryButton.ButtonPushedFcn = createCallbackFcn(app, @ClearTrajectoryButtonPushed, true);
            app.ClearTrajectoryButton.FontSize = 14;
            app.ClearTrajectoryButton.Position = [313 341 115 26];
            app.ClearTrajectoryButton.Text = 'Clear Trajectory';

            % Create GameRestartButton
            app.GameRestartButton = uibutton(app.FlappyBirdControllerUIFigure, 'push');
            app.GameRestartButton.ButtonPushedFcn = createCallbackFcn(app, @GameRestartButtonPushed, true);
            app.GameRestartButton.FontSize = 14;
            app.GameRestartButton.Position = [318.5 290 103 26];
            app.GameRestartButton.Text = 'Game Restart';

            % Create BoundarySettingPanel
            app.BoundarySettingPanel = uipanel(app.FlappyBirdControllerUIFigure);
            app.BoundarySettingPanel.Title = 'Boundary Setting';
            app.BoundarySettingPanel.FontWeight = 'bold';
            app.BoundarySettingPanel.FontSize = 16;
            app.BoundarySettingPanel.Position = [38 11 170 150];

            % Create XOffsetSpinnerLabel
            app.XOffsetSpinnerLabel = uilabel(app.BoundarySettingPanel);
            app.XOffsetSpinnerLabel.HorizontalAlignment = 'right';
            app.XOffsetSpinnerLabel.Position = [3 23 48 22];
            app.XOffsetSpinnerLabel.Text = 'X Offset';

            % Create XOffsetSpinner
            app.XOffsetSpinner = uispinner(app.BoundarySettingPanel);
            app.XOffsetSpinner.Step = 0.5;
            app.XOffsetSpinner.Limits = [25 50];
            app.XOffsetSpinner.ValueDisplayFormat = '%.2f';
            app.XOffsetSpinner.ValueChangedFcn = createCallbackFcn(app, @XOffsetSpinnerValueChanged, true);
            app.XOffsetSpinner.Position = [66 23 100 22];
            app.XOffsetSpinner.Value = 30;

            % Create YOffsetSpinnerLabel
            app.YOffsetSpinnerLabel = uilabel(app.BoundarySettingPanel);
            app.YOffsetSpinnerLabel.HorizontalAlignment = 'right';
            app.YOffsetSpinnerLabel.Position = [3 79 48 22];
            app.YOffsetSpinnerLabel.Text = 'Y Offset';

            % Create YOffsetSpinner
            app.YOffsetSpinner = uispinner(app.BoundarySettingPanel);
            app.YOffsetSpinner.Step = 0.5;
            app.YOffsetSpinner.Limits = [5 40];
            app.YOffsetSpinner.ValueDisplayFormat = '%.2f';
            app.YOffsetSpinner.ValueChangedFcn = createCallbackFcn(app, @YOffsetSpinnerValueChanged, true);
            app.YOffsetSpinner.Position = [66 79 100 22];
            app.YOffsetSpinner.Value = 10;

            % Create PIDTuningPanel
            app.PIDTuningPanel = uipanel(app.FlappyBirdControllerUIFigure);
            app.PIDTuningPanel.Title = 'PID Tuning';
            app.PIDTuningPanel.FontWeight = 'bold';
            app.PIDTuningPanel.FontSize = 16;
            app.PIDTuningPanel.Position = [252 11 170 150];

            % Create KiSpinnerLabel
            app.KiSpinnerLabel = uilabel(app.PIDTuningPanel);
            app.KiSpinnerLabel.HorizontalAlignment = 'right';
            app.KiSpinnerLabel.Position = [15 52 25 22];
            app.KiSpinnerLabel.Text = 'Ki';

            % Create KiSpinner
            app.KiSpinner = uispinner(app.PIDTuningPanel);
            app.KiSpinner.Step = 0.05;
            app.KiSpinner.Limits = [0 10];
            app.KiSpinner.ValueDisplayFormat = '%.2f';
            app.KiSpinner.ValueChangedFcn = createCallbackFcn(app, @KiSpinnerValueChanged, true);
            app.KiSpinner.Enable = 'off';
            app.KiSpinner.Position = [55 52 100 22];

            % Create KpSpinnerLabel
            app.KpSpinnerLabel = uilabel(app.PIDTuningPanel);
            app.KpSpinnerLabel.HorizontalAlignment = 'right';
            app.KpSpinnerLabel.Position = [15 88 25 22];
            app.KpSpinnerLabel.Text = 'Kp';

            % Create KpSpinner
            app.KpSpinner = uispinner(app.PIDTuningPanel);
            app.KpSpinner.Step = 0.05;
            app.KpSpinner.Limits = [0 10];
            app.KpSpinner.ValueDisplayFormat = '%.2f';
            app.KpSpinner.ValueChangedFcn = createCallbackFcn(app, @KpSpinnerValueChanged, true);
            app.KpSpinner.Enable = 'off';
            app.KpSpinner.Position = [55 88 100 22];
            app.KpSpinner.Value = 1;

            % Create KdSpinnerLabel
            app.KdSpinnerLabel = uilabel(app.PIDTuningPanel);
            app.KdSpinnerLabel.HorizontalAlignment = 'right';
            app.KdSpinnerLabel.Position = [15 16 25 22];
            app.KdSpinnerLabel.Text = 'Kd';

            % Create KdSpinner
            app.KdSpinner = uispinner(app.PIDTuningPanel);
            app.KdSpinner.Step = 0.05;
            app.KdSpinner.Limits = [0 10];
            app.KdSpinner.ValueDisplayFormat = '%.2f';
            app.KdSpinner.ValueChangedFcn = createCallbackFcn(app, @KdSpinnerValueChanged, true);
            app.KdSpinner.Enable = 'off';
            app.KdSpinner.Position = [55 16 100 22];

            % Create GameSpeedSliderLabel
            app.GameSpeedSliderLabel = uilabel(app.FlappyBirdControllerUIFigure);
            app.GameSpeedSliderLabel.HorizontalAlignment = 'right';
            app.GameSpeedSliderLabel.FontSize = 14;
            app.GameSpeedSliderLabel.Position = [320 238 88 22];
            app.GameSpeedSliderLabel.Text = 'Game Speed';

            % Create GameSpeedSlider
            app.GameSpeedSlider = uislider(app.FlappyBirdControllerUIFigure);
            app.GameSpeedSlider.Limits = [1 5];
            app.GameSpeedSlider.MajorTicks = [1 2 3 4 5];
            app.GameSpeedSlider.MajorTickLabels = {'1', '2', '3', '4', '5'};
            app.GameSpeedSlider.ValueChangedFcn = createCallbackFcn(app, @GameSpeedSliderValueChanged, true);
            app.GameSpeedSlider.MinorTicks = [];
            app.GameSpeedSlider.Position = [320 226 103 3];
            app.GameSpeedSlider.Value = 1;

            % Create Lamp
            app.Lamp = uilamp(app.FlappyBirdControllerUIFigure);
            app.Lamp.Position = [19 476 20 20];
            app.Lamp.Color = [1 0 0];

            % Create FlappyBirdControllerLabel
            app.FlappyBirdControllerLabel = uilabel(app.FlappyBirdControllerUIFigure);
            app.FlappyBirdControllerLabel.FontSize = 20;
            app.FlappyBirdControllerLabel.Position = [126 474 200 25];
            app.FlappyBirdControllerLabel.Text = 'Flappy Bird Controller';

            % Create CheckBox
            app.CheckBox = uicheckbox(app.FlappyBirdControllerUIFigure);
            app.CheckBox.ValueChangedFcn = createCallbackFcn(app, @CheckBoxValueChanged, true);
            app.CheckBox.Text = '';
            app.CheckBox.Position = [403 139 25 22];

            % Create UIAxes
            app.UIAxes = uiaxes(app.FlappyBirdControllerUIFigure);
            title(app.UIAxes, 'Trajectory')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.FontName = 'Times New Roman';
            app.UIAxes.XLim = [0 144];
            app.UIAxes.YLim = [0 200];
            app.UIAxes.ZLim = [0 1];
            app.UIAxes.TitleFontWeight = 'bold';
            app.UIAxes.Box = 'on';
            app.UIAxes.Interruptible = 'off';
            app.UIAxes.Position = [1 180 288 200];

            % Show the figure after all components are created
            app.FlappyBirdControllerUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = flappy_bird_controller_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.FlappyBirdControllerUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.FlappyBirdControllerUIFigure)
        end
    end
end