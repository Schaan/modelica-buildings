within Buildings.Fluid.Sensors;
model SpecificEntropyTwoPort "Ideal two port sensor for the specific entropy"
  extends Buildings.Fluid.Sensors.BaseClasses.PartialDynamicFlowSensor;
  extends Modelica.Icons.RotationalSensor;
  Modelica.Blocks.Interfaces.RealOutput s(final quantity="SpecificEntropy",
                                          final unit="J/(kg.K)",
                                          start=s_start)
    "Specific entropy of the passing fluid"
    annotation (Placement(transformation(
        origin={0,110},
        extent={{10,-10},{-10,10}},
        rotation=270)));
  parameter Modelica.SIunits.SpecificEntropy s_start=
    Medium.specificEntropy_pTX(Medium.p_default, Medium.T_default, Medium.X_default)
    "Initial or guess value of output (= state)"
    annotation (Dialog(group="Initialization"));
  Modelica.SIunits.SpecificEntropy sMed(start=s_start)
    "Medium entropy to which the sensor is exposed";
protected
  Medium.SpecificEntropy s_a_inflow
    "Specific entropy of inflowing fluid at port_a";
  Medium.SpecificEntropy s_b_inflow
    "Specific entropy of inflowing fluid at port_b or s_a_inflow, if uni-directional flow";
initial equation
  if dynamic then
    if initType == Modelica.Blocks.Types.Init.SteadyState then
      der(s) = 0;
    elseif initType == Modelica.Blocks.Types.Init.InitialState or
           initType == Modelica.Blocks.Types.Init.InitialOutput then
      s = s_start;
    end if;
  end if;
equation
  if allowFlowReversal then
     s_a_inflow = Medium.specificEntropy(Medium.setState_phX(port_b.p, port_b.h_outflow, port_b.Xi_outflow));
     s_b_inflow = Medium.specificEntropy(Medium.setState_phX(port_a.p, port_a.h_outflow, port_a.Xi_outflow));
     s = Modelica.Fluid.Utilities.regStep(port_a.m_flow, s_a_inflow, s_b_inflow, m_flow_small);
  else
     s = Medium.specificEntropy(Medium.setState_phX(port_b.p, port_b.h_outflow, port_b.Xi_outflow));
     s_a_inflow = s;
     s_b_inflow = s;
  end if;
  // Output signal of sensor
  if dynamic then
    der(s) = (sMed-s)*k/tau;
  else
    s = sMed;
  end if;
annotation (defaultComponentName="senSpeEnt",
  Diagram(coordinateSystem(preserveAspectRatio=true,  extent={{-100,-100},{
            100,100}})),
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
        graphics={
        Text(
          extent={{120,120},{0,90}},
          lineColor={0,0,0},
          textString="s"),
        Line(points={{0,100},{0,70}}, color={0,0,127}),
        Line(points={{-100,0},{-70,0}}, color={0,128,255}),
        Line(points={{70,0},{100,0}}, color={0,128,255})}),
  Documentation(info="<html>
<p>
This component monitors the specific entropy of the passing fluid. 
The sensor is ideal, i.e. it does not influence the fluid.
If the parameter <code>tau</code> is non-zero, then its output
is computed using a first order differential equation. 
Setting <code>tau=0</code> is <i>not</i> recommend. See
<a href=\"modelica://Buildings.Fluid.Sensors.UsersGuide\">
Buildings.Fluid.Sensors.UsersGuide</a> for an explanation.
</p>
</html>
", revisions="<html>
<html>
<p>
<ul>
<li>
June 3, 2011 by Michael Wetter:<br>
Revised implementation to add dynamics in such a way that 
the time constant increases as the mass flow rate tends to zero.
This significantly improves the numerics.
</li>
<li>
September 29, 2009, by Michael Wetter:<br>
First implementation.
</li>
</ul>
</html>"));
end SpecificEntropyTwoPort;
