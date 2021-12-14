"""Classes modelling chemicals and substances
"""

from collections import defaultdict
import decimal


"""
material stuff
"""


class MaterialModel:
    # instance_names = []
    def __init__(self, name, properties, state):
        self.name = name  # is there a way to ensure only one material model exists for a given name?
        # the answer is yes: make the class track the names of objects and o
        # or material model is a metaclass(type), do similar override there
        # __init_subclass__() #
        # and liquid water could be a class of material, error : 'water already exists!''
        # you can use factories instead, material model is a factory for classes
        # doesnt involve inheritence per-se

        # state is a state of matter (solid, liquid, gas)
        self.properties = properties
        self.state = state

    def __repr__(self):
        return f"MaterialModel of {self.name}"

    def __hash__(self):
        return hash(self.name)


class MixtureModel:
    """A really hacked out extensive form of mixture"""

    def __init__(self):
        """
        You can add components to the mixture, but can't remove them (unless, exception)
        """

        self.solutes = defaultdict(lambda: 0)  # solid(s)
        self.solvents = defaultdict(lambda: 0)  # liquid(s)

    def add(self, amounts):

        for mat, amount in amounts.items():
            # we can probably use Pint for liquid/solid checking
            if isinstance(mat, MaterialModel):
                if mat.state == "liquid":
                    self.solvents[mat] += amount
                elif mat.state == "solid":
                    self.solutes[mat] += amount
            elif isinstance(mat, MixtureModel):
                self.add({**mat.solvents, **mat.solutes})

    @property
    def state(self):
        """Good first pass"""
        if len(self.solvents) > 0:
            return "liquid"
        elif len(self.solutes) > 0:
            return "solid"
        else:
            return None

    @property
    def measure(self):
        return [sum(list(self.solutes.values())), sum(list(self.solvents.values()))]
        # adds up total amount of solute (mass or moles) and total volume of solvent. stores these separately

    @property
    def total_measure(self):
        if self.state == "liquid":
            return self.measure[1]
        elif self.state == "solid":
            return self.measure[0]

        """
        this is OK but can be imporved by: 
            * using SolUD
        """

    @property
    def total_volume(self):
        return self.measure[
            1
        ]  # todo: account for nonideal solute mixing (bulk crystal density)

    @property
    def conc(self):
        return (
            self.measure[0] / self.measure[1]
        )  # for concentration, divide total moles/mass by total volume
        # this is a good start, but not quite right. need separate conc for each solute.

    @property
    def materials(self):
        return {**self.solutes, **self.solvents}

    def __repr__(self):  # solutes and solvents together
        mat_names = [m.name for d in (self.solutes, self.solvents) for m in d.keys()]
        return f"Mixture Model containing {', '.join(mat_names)}"

    def __len__(
        self,
    ):  # solutes and solvents together ... perhaps useful to report the number of each seperately?
        return len(self.solutes) + len(self.solvents)

    def __hash__(self):
        return hash(str(self.solutes) + str(self.solvents) + str(id(self)))


"""
action stuff
"""

from abc import abstractmethod, ABC


class ActionBaseClass:
    def __init__(self):
        """The initializer will take parameters, source, and dest"""
        pass

    def do(self):
        """Do method describes what the action does to the workspace"""
        pass

    def undo(self):
        """Inverse of self.do"""
        pass


"""
Workspace stuff: vessels, workspace, etc
"""


class Vessel:
    """A reactionware vessel.

    Something we can add and remove materials from.

    Contains a MixtureModel of all materials added to it.

    Attributes:
        :mixture: dict, maps material to amount of material present
            in the vessel

    Methods:
        :add: add materail(s) to the vessel
        :remove: remove material(s) from the vessel
    """

    def __init__(self, name, temp=None):
        self.mixture = MixtureModel()
        self.name = name
        self.temp = temp  # not sure if this belongs here or on material...

    def add(self, material_amounts):
        self.mixture.add(material_amounts)

    def remove(self, amount):
        """Remove some of the mixture from the container

        Return the removed portion

        name is an optional argument for the name of the removed mixture

        For now: assumes that everything is mixed perfectly, so that when you remove
        some amount of the mixture, it removes the same percent of each mixture element.

        Obviously this isnt true in all cases: e.g. removing oil from an oil-water mixture is possible
        and organic-inorganic phase separations are very common: we should be able to model them
        This is a good next step.
        """

        if not isinstance(amount, (int, float, decimal.Decimal)):
            raise TypeError(f"Amount should be numeric, got {type(amount)}")

        if amount < 0:
            raise ValueError("Cannot remove a negative amount")

        if self.mixture.total_measure == 0:
            raise ValueError("Cannot remove from emtpy Vessel")

        prop_decrease = (
            self.mixture.total_measure - amount
        ) / self.mixture.total_measure
        removed_mixture = MixtureModel()
        for k in self.mixture.solvents.keys():
            amt = self.mixture.solvents[k]
            self.mixture.solvents[k] *= prop_decrease
            removed_mixture.solvents[k] = amt * (
                1 - prop_decrease
            )  # the rest gets returned
        for k in self.mixture.solutes.keys():
            amt = self.mixture.solutes[k]
            self.mixture.solutes[k] *= prop_decrease
            removed_mixture.solutes[k] = amt * (
                1 - prop_decrease
            )  # the rest gets returned

        return removed_mixture

    @property
    def state(self):
        """Convenience method: whats going on in this vessel right now?"""
        return {
            "solvents": dict(self.mixture.solvents),
            "solutes": dict(self.mixture.solutes),
            "temp": self.temp
            # should probably add concentration, once thats finished
        }

    def __repr__(self):

        if len(self.mixture) > 0:
            _str = ", ".join([f"{k} ({v})" for k, v in self.mixture.materials.items()])
        else:
            _str = "{}"

        return f"{self.name}, a Vessel object containing: {_str}"


class Singleton(type):
    """https://stackoverflow.com/questions/6760685/creating-a-singleton-in-python"""

    _instances = {}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super(Singleton, cls).__call__(*args, **kwargs)
        return cls._instances[cls]


class Workspace(metaclass=Singleton):
    def __init__(self):
        """A list-like singleton that keeps track of vessels in the workspace space.
        Supports vessel adding, removing, and state reporting"""
        self.vessels = []

    @property
    def state(self):
        return {vessel.name: vessel.state for vessel in self}

    def add(self, vessel):
        """Add a vessel to the workspace"""
        self.vessels.append(vessel)

    def remove(self, vessel):
        """Remove a vessel frome the workspace"""
        self.vessels.remove(vessel)

    def __iter__(self):
        """It's iterable!"""
        for vessel in self.vessels:
            yield vessel

    def __len__(self):
        """It has a length!"""
        return len(self.vessels)

    def __contains__(self, key):
        """You can check if stuff is in it!"""
        return key in self.vessels

    def __getitem__(self, i):
        """You can get stuff from it!"""
        return self.vessels[i]

    def __repr__(self):
        names = ", ".join([vessel.name for vessel in self.vessels])
        return f"Workspace object containing vessels [{names}]"


workspace = Workspace()
