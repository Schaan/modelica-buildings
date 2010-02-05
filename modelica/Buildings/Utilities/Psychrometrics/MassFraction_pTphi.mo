within Buildings.Utilities.Psychrometrics;
block MassFraction_pTphi
  "Return steam mass fraction as a function of relative humidity phi and temperature T"
  extends
    Buildings.Utilities.Psychrometrics.BaseClasses.HumidityRatioVaporPressure;
 replaceable package Medium = Modelica.Media.Interfaces.PartialCondensingGases
    "Medium model";
  annotation (Documentation(info="<html>
<p>
Block to compute the water vapor concentration based on
pressure, temperature and relative humidity.
</p>
<p>If <tt>use_p_in</tt> is false (default option), the <tt>p</tt> parameter
is used as atmospheric pressure, 
and the <tt>p_in</tt> input connector is disabled; 
if <tt>use_p_in</tt> is true, then the <tt>p</tt> parameter is ignored, 
and the value provided by the input connector is used instead.
</p>
</html>", revisions="<html>
<ul>
<li>
February 4, 2010 by Michael Wetter:<br>
First implementation.
</li>
</ul>
</html>"), Icon(graphics={
        Text(
          extent={{-96,16},{-54,-22}},
          lineColor={0,0,0},
          textString="T"),
        Text(
          extent={{-86,-18},{-36,-100}},
          lineColor={0,0,0},
          textString="phi"),
        Text(
          extent={{26,56},{90,-54}},
          lineColor={0,0,0},
          textString="X_steam")}));

public
  Modelica.Blocks.Interfaces.RealInput T(final unit="K",
                                           displayUnit="degC",
                                           min = 0) "Temperature" 
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
  Modelica.Blocks.Interfaces.RealInput phi(min = 0, max=1)
    "Relative humidity (0...1)" 
    annotation (Placement(transformation(extent={{-140,-80},{-100,-40}})));
  Modelica.Blocks.Interfaces.RealOutput X[Medium.nX](min = 0, max=1)
    "Steam mass fraction" 
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));
protected
  constant Real k = 0.621964713077499 "Ratio of molar masses";
  Modelica.SIunits.AbsolutePressure psat "Saturation pressure";
 parameter Integer iWat(min=1, fixed=false) "Index for water substance";

initial algorithm
  iWat :=1;
    for i in 1:Medium.nXi loop
      if Modelica.Utilities.Strings.isEqual(Medium.substanceNames[i], "Water") then
        iWat :=i;
      end if;
    end for;

algorithm
  psat := Medium.saturationPressure(T);
  X[iWat] := phi*k/(k*phi+p_in_internal/psat-phi);
  //sum(X[:]) = 1; // The formulation with a sum in an equation section leads to a nonlinear equation system
  X[if iWat == 1 then 2 else 1] := 1 - X[iWat];
end MassFraction_pTphi;
