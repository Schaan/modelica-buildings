model Stratifier "Model to reduce the numerical dissipation in a tank" 
  extends Buildings.BaseClasses.BaseIcon;
  replaceable package Medium = 
    Modelica.Media.Interfaces.PartialMedium "Medium model"  annotation (
      choicesAllMatching = true);
  annotation (Documentation(info="<html>
<p>
This model reduces the numerical dissipation that is introduced
by the standard upwind discretization scheme.
The model is described by Wischhusen (2006).
Since we use this model in conjunction with Modelica_Fluid,
we compute a heat flux that need to be added to each volume
in order to give the results published in the above paper.
The model is used by
<a href=\"Modelica:Buildings.Fluids.Storage.StratifiedEnhanced\">
Buildings.Fluids.Storage.StratifiedEnhanced</a>.
</p>
<h4>References</h4>
<p>
Wischhusen Stefan, 
<a href=\"http://www.modelica.org/events/modelica2006/Proceedings/sessions/Session3a2.pdf\">An Enhanced Discretization Method for Storage
Tank Models within Energy Systems</a>, 
<i>Modelica Conference</i>,
Vienna, Austria, September 2006.
</p>
</html>", revisions="<html>
<ul>
<li>
October 30, 2008 by Michael Wetter:<br>
Modified interpolation function to prevent chattering.
</li>
<li>
October 28, 2008 by Michael Wetter:<br>
Fixed sign error based on feedback from Stefan Wischhusen.
</li>
<li>
October 23, 2008 by Michael Wetter:<br>
First implementation.
</li>
</ul>
</html>"),
Icon(Rectangle(extent=[-100,100; 100,-100], style(
          color=0,
          rgbcolor={0,0,0},
          fillColor=7,
          rgbfillColor={255,255,255})), Text(
        extent=[-58,20; 82,-102],
        style(
          color=0,
          rgbcolor={0,0,0},
          fillColor=7,
          rgbfillColor={255,255,255},
          fillPattern=1),
        string="exp(...)")));
  
  parameter Integer nSeg(min=2) = 2 "Number of volume segments";
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a[nSeg] heatPort 
    "Heat input into the volumes" 
    annotation (extent=[90,-10; 110,10]);
  
  Modelica.Blocks.Interfaces.RealInput m_flow 
    "Mass flow rate from port a to port b" 
    annotation (extent=[-140,62; -100,102]);
  
  Modelica.Blocks.Interfaces.RealInput[nSeg+1] H_flow 
    "Enthalpy flow between the volumes" 
    annotation (extent=[-140,-100; -100,-60]);
  Modelica.SIunits.Enthalpy[nSeg+2] hOut 
    "Extended vector with new outlet enthalpies to reduce numerical dissipation";
  Modelica.SIunits.Enthalpy[nSeg+2] h 
    "Extended vector with port enthalpies, needed to simplify loop";
  
  parameter Real a(min=0)= 1E-4 
    "Tuning factor. a=0 is equivalent to not using this model";
  parameter Modelica.SIunits.Temperature delta = 1 
    "Temperature difference for which which exp(-|x|) will be approximated";
  
  Modelica_Fluid.Interfaces.FluidPort_a[nSeg+2] fluidPort(
      redeclare each package Medium = Medium) 
    "Fluid port, needed to get pressure, temperature and species concentration"
    annotation (extent=[-110,-10; -90,10]);
protected 
  Integer s(min=-1, max=1) "Index shift to pick up or down volume";
   parameter Medium.ThermodynamicState sta0 = Medium.setState_pTX(T=Medium.T_default,
         p=Medium.p_default, X=Medium.X_default[1:Medium.nXi]);
   parameter Modelica.SIunits.SpecificHeatCapacity cp0=Medium.specificHeatCapacityCp(sta0) 
    "Density, used to compute fluid volume";
  Real[nSeg] intArg "Argument for interpolation function";
  parameter Real intDel=a*cp0*delta 
    "Scaling argument delta for interpolation function";
equation 
  // assign zero flow conditions at port
  fluidPort[:].m_flow = zeros(nSeg+2);
  fluidPort[:].H_flow = zeros(nSeg+2);
  fluidPort[:].mXi_flow = zeros(nSeg+2, Medium.nXi);
  
  // assign extended enthalpy vectors
  h[:] = fluidPort[:].h;
  // in loop, i+1-s is the "down" volume, i+1+s is the "up" volume
  s = if m_flow > 0 then 1 else -1;
  hOut[1] = h[1];
  hOut[nSeg+2] = h[nSeg+2];
  for i in 2:(nSeg+1) loop
     /*
     // original implementation that causes chattering
     intArg[i-1] = -a * abs(h[i-s]-h[i]);
     hOut[i] = (h[i]-h[i+s]) * exp(intArg[i-1])   + h[i+s];
     */
     // approximation that is once continuously differentiable
     // and does not cause chattering
     intArg[i-1] = a * (h[i-s]-h[i]);
     hOut[i] = (h[i]-h[i+s]) * Buildings.Utilities.Math.smoothExponential( intArg[i-1], intDel)   + h[i+s];
  end for;
  for i in 1:nSeg loop
     if s > 0 then
       heatPort[i].Q_flow = -m_flow * (hOut[i]-hOut[i+1])   +H_flow[i]   -H_flow[i+1];
     else
       heatPort[i].Q_flow = +m_flow * (hOut[i+2]-hOut[i+1]) -H_flow[i+1] +H_flow[i];
     end if;
  end for;
end Stratifier;