within Buildings.Utilities.Math.Functions;
function smoothExponential
  "Once continuously differentiable approximation to exp(-|x|) in interval |x| < delta"

    annotation (smoothOrder=1, Documentation(info="<html>
<p>
Function to provide a once continuously differentiable approximation 
to <tt>exp(- |x| )</tt>
in the interval <tt>|x| < delta</tt> for some positive <tt>delta</tt>
</p>
</html>", revisions="<html>
<ul>
<li>
October 30, 2008, by Michael Wetter:<br>
First implementation to reduce chattering in 
<a href=\"Modelica:Buildings.Fluids.Storage.BaseClasses.Stratifier\"</a>
Buildings.Fluids.Storage.BaseClasses.Stratifier</a>.
</li>
</ul>
</html>"));

  input Real x "Input argument";
  input Real delta "Transition point where approximation occurs";
  output Real y "Output argument";
protected
  Real absX "Absolute value of x";
  Real a2 "Coefficient for approximating function";
  Real a3 "Coefficient for approximating function";
  Real e;
  Real d2;
  Real x2;
algorithm
  absX :=abs(x);
  if absX > delta then
    y :=  exp(-absX);
  else
    d2 := delta*delta;
    e  := exp(-delta);
    a2 := (delta*e-4*(1-e))/2/d2;
    a3 := (e-1-a2*d2)/d2/d2;
    x2 := x*x;
    y  := 1+x2*(a2+x2*a3);
  end if;
end smoothExponential;