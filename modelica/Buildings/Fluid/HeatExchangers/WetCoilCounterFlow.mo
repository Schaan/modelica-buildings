within Buildings.Fluid.HeatExchangers;
model WetCoilCounterFlow
  "Counterflow coil with discretization along the flow paths and humidity condensation"
  extends Buildings.Fluid.HeatExchangers.DryCoilCounterFlow(
    final allowCondensation = true,
    ele(redeclare each Buildings.Fluid.MixingVolumes.MixingVolumeMoistAir vol2(
          final use_HeatTransfer = true)));

  Modelica.SIunits.HeatFlowRate QSen2_flow
    "Sensible heat input into air stream (negative if air is cooled)";
  Modelica.SIunits.HeatFlowRate QLat2_flow
    "Latent heat input into air (negative if air is dehumidified)";
  Real SHR(
    min=0,
    max=1,
    unit="1") "Sensible to total heat ratio";

  Modelica.SIunits.MassFlowRate mWat_flow "Water flow rate";

equation
  mWat_flow = sum(ele[i].vol2.mWat_flow for i in 1:nEle);
  QLat2_flow = sum(Medium2.enthalpyOfCondensingGas(ele[i].vol2.medium.T)*ele[i].vol2.mWat_flow for i in 1:nEle);
  Q2_flow = QSen2_flow + QLat2_flow;
  Q2_flow*SHR = QSen2_flow;
 annotation (
    Documentation(info="<html>
<p>
Model of a discretized coil with water vapor condensation.
The coil consists of two flow paths which are, at the design flow direction,
in opposite direction to model a counterflow heat exchanger.
The flow paths are discretized into <tt>nEle</tt> elements. 
Each element is modeled by an instance of
<a href=\"modelica://Buildings.Fluid.HeatExchangers.BaseClasses.HexElement\">
Buildings.Fluid.HeatExchangers.BaseClasses.HexElement</a>.
Each element has a state variable for the metal. Depending
on the value of the boolean parameters <tt>steadyState_1</tt> and
<tt>steadyState_2</tt>, the fluid states are modeled dynamically or in steady
state.
</p>
<p>
The convective heat transfer coefficients can, for each fluid individually, be 
computed as a function of the flow rate and/or the temperature,
or assigned to a constant. This computation is done using an instance of
<a href=\"modelica://Buildings.Fluid.HeatExchangers.BaseClasses.HADryCoil\">
Buildings.Fluid.HeatExchangers.BaseClasses.HADryCoil</a>.
</p>
<p>
In this model, the water (or liquid) flow path
needs to be connected to <tt>port_a1</tt> and <tt>port_b1</tt>, and
the air flow path needs to be connected to the other two ports.
</p>
<p>
The mass transfer from the fluid 2 to the metal is computed using a similarity law between
heat and mass transfer, as implemented by the model
<a href=\"modelica://Buildings.Fluid.HeatExchangers.BaseClasses.MassExchange\">
Buildings.Fluid.HeatExchangers.BaseClasses.MassExchange</a>. 
</p>
<p>
This model can only be used with medium models that
implement the function <tt>enthalpyOfLiquid</tt> and that contain
an integer variable <tt>Water</tt> whose value is the element number where
the water vapor is stored in the species concentration vector. Examples for
such media are
<a href=\"modelica://Buildings.Media.PerfectGases.MoistAir\">
Buildings.Media.PerfectGases.MoistAir</a> and
<a href=\"Modelica:Modelica.Media.Air.MoistAir\">
Modelica.Media.Air.MoistAir</a>.
</p>
<p>
To model this coil for conditions without humidity condensation, use the model 
<a href=\"modelica://Buildings.Fluid.HeatExchangers.DryCoilCounterFlow\">
Buildings.Fluid.HeatExchangers.DryCoilCounterFlow</a> instead of this model.
</p>
</html>", revisions="<html>
<ul>
<li>
May 27, 2010, by Michael Wetter:<br>
First implementation.
</li>
</ul>
</html>"), Icon(coordinateSystem(
        preserveAspectRatio=false,
        extent={{-100,-100},{100,100}},
        grid={2,2},
        initialScale=0.5), graphics={
        Rectangle(
          extent={{-70,80},{70,-80}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{36,80},{40,-80}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-40,80},{-36,-80}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-2,80},{2,-80}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,-55},{101,-65}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,127,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-98,65},{103,55}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid)}),
    Diagram(coordinateSystem(
        preserveAspectRatio=true,
        extent={{-100,-100},{100,100}},
        grid={2,2},
        initialScale=0.5), graphics={Text(
          extent={{60,72},{84,58}},
          lineColor={0,0,255},
          textString="water-side"), Text(
          extent={{50,-32},{90,-38}},
          lineColor={0,0,255},
          textString="air-side")}));
end WetCoilCounterFlow;