within Buildings.Fluid.Storage.BaseClasses;
model ThirdOrderStratifier
  "Model to reduce the numerical dissipation in a tank"
  extends Buildings.BaseClasses.BaseIcon;
  replaceable package Medium =
    Modelica.Media.Interfaces.PartialMedium "Medium model"  annotation (
      choicesAllMatching = true);

  parameter Integer nSeg(min=2) = 2 "Number of volume segments";
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a[nSeg] heatPort
    "Heat input into the volumes"
    annotation (Placement(transformation(extent={{90,-10},{110,10}}, rotation=0)));

  Modelica.Blocks.Interfaces.RealInput m_flow
    "Mass flow rate from port a to port b"
    annotation (Placement(transformation(extent={{-140,62},{-100,102}},
          rotation=0)));

  Modelica.Blocks.Interfaces.RealInput[nSeg+1] H_flow
    "Enthalpy flow between the volumes"
    annotation (Placement(transformation(extent={{-140,-100},{-100,-60}},
          rotation=0)));

  Modelica.Fluid.Interfaces.FluidPort_a[nSeg+2] fluidPort(
      redeclare each package Medium = Medium)
    "Fluid port, needed to get pressure, temperature and species concentration"
    annotation (Placement(transformation(extent={{-110,-10},{-90,10}}, rotation=
           0)));

protected
  Modelica.SIunits.SpecificEnthalpy[nSeg+2] hOut
    "Extended vector with new outlet enthalpies to reduce numerical dissipation";
  Modelica.SIunits.SpecificEnthalpy[nSeg+2] h
    "Extended vector with port enthalpies, needed to simplify loop";
  Modelica.SIunits.HeatFlowRate Q_flow[nSeg]
    "Heat exchange computed using upwind third order discretization scheme";
  Modelica.SIunits.HeatFlowRate Q_flow_upWind
    "Heat exchange computed using upwind third order discretization scheme";

  Integer s(min=-1, max=1) "Index shift to pick up or down volume";
  parameter Medium.ThermodynamicState sta0 = Medium.setState_pTX(T=Medium.T_default,
         p=Medium.p_default, X=Medium.X_default[1:Medium.nXi]);
  parameter Modelica.SIunits.SpecificHeatCapacity cp0=Medium.specificHeatCapacityCp(sta0)
    "Density, used to compute fluid volume";
equation
  // assign zero flow conditions at port
  fluidPort[:].m_flow = zeros(nSeg+2);
  fluidPort[:].h_outflow = zeros(nSeg+2);
  fluidPort[:].Xi_outflow = zeros(nSeg+2, Medium.nXi);
  fluidPort[:].C_outflow  = zeros(nSeg+2, Medium.nC);

  // assign extended enthalpy vectors
  for i in 1:nSeg+2 loop
    h[i] = inStream(fluidPort[i].h_outflow);
  end for;
  // in loop, i+1-s is the "down" volume, i+1+s is the "up" volume
  s = if m_flow > 0 then 1 else -1;
  hOut[1] = h[1];
  hOut[nSeg+2] = h[nSeg+2];

  for i in 1:nSeg loop
    // Third order scheme to approximate interface temperature
    if ( s > 0) then
      hOut[i+1] = if ( i==1) then  h[2] else
        0.5*(h[i+1+s]+h[i+1])-0.125*(h[i+2]+h[i]-2*h[i+1]);
    else
      hOut[i+1] = if ( i==nSeg) then  h[end-1] else
        0.5*(h[i+1+s]+h[i+1])-0.125*(h[i+2]+h[i]-2*h[i+1]);
    end if;
  end for;
  for i in 1:nSeg loop
     if s > 0 then
       Q_flow[i] = m_flow * (hOut[i+1] -hOut[i])  +H_flow[i] -H_flow[i+1];
     else
       Q_flow[i] = m_flow * (hOut[i+2]-hOut[i+1]) +H_flow[i] -H_flow[i+1];
     end if;
     end for;
     Q_flow_upWind = sum(Q_flow[i] for i in 1:nSeg);
  for i in 1:nSeg loop
    heatPort[i].Q_flow = Q_flow[i] - Q_flow_upWind/nSeg;
  end for;
  annotation (Documentation(info="<html>
<p>
This model reduces the numerical dissipation that is introduced
by the standard first-order upwind discretization scheme which is 
created when connecting fluid volumes in series.
</p>
<p>
Since the model is used in conjunction with 
<a href=\"modelica://Modelica.Fluid\">
Modelica.Fluid</a>,
it computes a heat flux that needs to be added to each volume
in order to give the results that a third-order upwind discretization
scheme would give.
If a standard third-order upwind discretization scheme were to be used,
then the temperatures of the elements that face the tank inlet and outlet ports
would overshoot by a few tenths of a Kelvin.
To reduce this overshoot, the model uses a first order scheme at the 
boundary elements, and it adds a term that ensures that the energy balance
is satisfied. Without this term, small numerical
errors in the energy balance, introduced by the third order discretization scheme,
would occur.
</p>
<p>
The model is used by
<a href=\"modelica://Buildings.Fluid.Storage.StratifiedEnhanced\">
Buildings.Fluid.Storage.StratifiedEnhanced</a>.
</p>
</html>", revisions="<html>
<ul>
<li>
June 23, 2010 by Michael Wetter and Wangda Zuo:<br>
First implementation.
</li>
</ul>
</html>"),
Icon(coordinateSystem(preserveAspectRatio=true,  extent={{-100,-100},{100,100}}),
        graphics={Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-48,66},{48,34}},
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{-48,34},{48,2}},
          fillColor={166,0,0},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None,
          lineColor={0,0,0}),
        Rectangle(
          extent={{-48,2},{48,-64}},
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None,
          lineColor={0,0,0})}));
end ThirdOrderStratifier;