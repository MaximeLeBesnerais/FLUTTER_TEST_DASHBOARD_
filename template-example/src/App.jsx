import React, { useState, useEffect, useMemo, useCallback } from "react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";
import {
  Shield,
  Swords,
  DollarSign,
  Users,
  Settings,
  Heart,
  Zap,
  ChevronsUp,
  UserPlus,
  BrainCircuit,
  MessageSquare,
  Briefcase,
  ChevronDown,
  ChevronUp,
  Trash2,
  Edit,
  LoaderCircle,
  ChevronsLeft,
  ChevronsRight,
  Wand2,
} from "lucide-react";

// --- HELPER COMPONENTS (Styled like shadcn/ui with a new theme) ---

const Card = ({ children, className = "" }) => (
  <div
    className={`bg-white dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-xl shadow-md ${className}`}
  >
    {children}
  </div>
);

const CardHeader = ({ children, className = "" }) => (
  <div
    className={`p-6 border-b border-slate-200 dark:border-slate-700 ${className}`}
  >
    {children}
  </div>
);

const CardTitle = ({ children, className = "" }) => (
  <h3
    className={`text-xl font-bold tracking-tight text-slate-900 dark:text-slate-100 ${className}`}
  >
    {children}
  </h3>
);

const CardDescription = ({ children, className = "" }) => (
  <p className={`text-sm text-slate-500 dark:text-slate-400 ${className}`}>
    {children}
  </p>
);

const CardContent = ({ children, className = "" }) => (
  <div className={`p-6 ${className}`}>{children}</div>
);

const Button = ({
  children,
  onClick,
  className = "",
  variant = "default",
  size = "default",
  disabled = false,
}) => {
  const baseStyles =
    "inline-flex items-center justify-center rounded-lg text-sm font-semibold transition-all duration-200 focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 dark:focus-visible:ring-offset-slate-900";
  const variants = {
    default:
      "bg-sky-500 text-white hover:bg-sky-600 focus-visible:ring-sky-500",
    destructive:
      "bg-red-500 text-white hover:bg-red-600 focus-visible:ring-red-500",
    outline:
      "border border-sky-500 bg-transparent hover:bg-sky-50 text-sky-600 dark:text-sky-400 dark:hover:bg-sky-900/50 focus-visible:ring-sky-500",
    ghost:
      "hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-600 dark:text-slate-300",
  };
  const sizes = {
    default: "h-10 px-5 py-2",
    sm: "h-9 rounded-md px-3",
    icon: "h-10 w-10",
  };
  const disabledStyles = "opacity-50 cursor-not-allowed";

  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={`${baseStyles} ${variants[variant]} ${sizes[size]} ${
        disabled ? disabledStyles : ""
      } ${className}`}
    >
      {children}
    </button>
  );
};

const Table = ({ children, className = "" }) => (
  <div className="relative w-full overflow-auto">
    <table className={`w-full caption-bottom text-sm ${className}`}>
      {children}
    </table>
  </div>
);
const TableHeader = ({ children, className = "" }) => (
  <thead
    className={`[&_tr]:border-b [&_tr]:border-slate-200 dark:[&_tr]:border-slate-700 ${className}`}
  >
    {children}
  </thead>
);
const TableBody = ({ children, className = "" }) => (
  <tbody className={`[&_tr:last-child]:border-0 ${className}`}>
    {children}
  </tbody>
);
const TableRow = ({ children, className = "" }) => (
  <tr
    className={`border-b border-slate-200 dark:border-slate-700 transition-colors hover:bg-slate-50 dark:hover:bg-slate-800/30 ${className}`}
  >
    {children}
  </tr>
);
const TableHead = ({ children, className = "" }) => (
  <th
    className={`h-12 px-6 text-left align-middle font-medium text-slate-500 dark:text-slate-400 ${className}`}
  >
    {children}
  </th>
);
const TableCell = ({ children, className = "" }) => (
  <td className={`p-6 align-middle ${className}`}>{children}</td>
);

const Input = ({ className = "", ...props }) => (
  <input
    className={`flex h-10 w-full rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-sm focus:outline-none focus-visible:ring-2 focus-visible:ring-sky-500 ${className}`}
    {...props}
  />
);

const Label = ({ children, className = "", ...props }) => (
  <label
    className={`text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 ${className}`}
    {...props}
  >
    {children}
  </label>
);

const Switch = ({ checked, onCheckedChange }) => (
  <button
    type="button"
    role="switch"
    aria-checked={checked}
    onClick={() => onCheckedChange(!checked)}
    className={`${
      checked ? "bg-sky-500" : "bg-slate-300 dark:bg-slate-700"
    } relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus-visible:ring-2 focus-visible:ring-sky-500`}
  >
    <span
      aria-hidden="true"
      className={`${
        checked ? "translate-x-5" : "translate-x-0"
      } pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out`}
    />
  </button>
);

const Modal = ({ isOpen, onClose, title, children }) => {
  if (!isOpen) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm">
      <Card className="w-11/12 max-w-lg">
        <CardHeader className="flex justify-between items-center">
          <CardTitle>{title}</CardTitle>
          <Button variant="ghost" size="icon" onClick={onClose}>
            X
          </Button>
        </CardHeader>
        <CardContent>{children}</CardContent>
      </Card>
    </div>
  );
};

const ProgressBar = ({ value, className = "" }) => (
  <div
    className={`w-full bg-slate-200 dark:bg-slate-700 rounded-full h-1.5 ${className}`}
  >
    <div
      className="bg-sky-500 h-1.5 rounded-full transition-all duration-500"
      style={{ width: `${Math.min(value, 100)}%` }}
    ></div>
  </div>
);

const ApiLoadingChip = () => (
  <div className="fixed bottom-5 left-1/2 -translate-x-1/2 z-50">
    <div className="flex items-center gap-2 px-4 py-2 bg-slate-900/80 dark:bg-slate-800/80 backdrop-blur-md text-white rounded-full shadow-lg">
      <LoaderCircle className="animate-spin h-4 w-4" />
      <span className="text-sm font-medium">Calling Gemini...</span>
    </div>
  </div>
);

// --- STATIC DATA & GAME CONSTANTS ---
const STATIC_GLADIATOR_NAMES = [
  "Spartacus",
  "Crixus",
  "Gannicus",
  "Oenomaus",
  "Varro",
  "Agron",
  "Duro",
  "Nasir",
  "Rhaskos",
  "Barca",
];
const STATIC_STAFF_CANDIDATES = [
  {
    name: "Lucius",
    role: "Trainer",
    cost: 500,
    effect: { type: "training_speed", value: 0.1 },
  },
  {
    name: "Aelia",
    role: "Healer",
    cost: 700,
    effect: { type: "healing_speed", value: 0.15 },
  },
  {
    name: "Marcus",
    role: "Scout",
    cost: 400,
    effect: { type: "better_opponents", value: 0.05 },
  },
  {
    name: "Gaia",
    role: "Accountant",
    cost: 1000,
    effect: { type: "fight_winnings", value: 0.1 },
  },
  {
    name: "Sura",
    role: "Medic",
    cost: 600,
    effect: { type: "healing_speed", value: 0.12 },
  },
  {
    name: "Varinius",
    role: "Drillmaster",
    cost: 800,
    effect: { type: "training_speed", value: 0.15 },
  },
];
const HEALING_COST_PER_HP = 5;
const TRAINING_COST = 100;
const PASSIVE_HEAL_AMOUNT = 1;
const PASSIVE_HEAL_INTERVAL = 5000;
const FIGHT_DURATION = 60000;

// --- GAME COMPONENTS ---

const Dashboard = ({ stats, gladiators }) => (
  <div className="space-y-6">
    <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">TOTAL REVENUE</CardTitle>
          <DollarSign className="h-4 w-4 text-slate-500" />
        </CardHeader>
        <CardContent>
          <div className="text-3xl font-bold">${stats.money}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">GLADIATORS</CardTitle>
          <Users className="h-4 w-4 text-slate-500" />
        </CardHeader>
        <CardContent>
          <div className="text-3xl font-bold">{stats.gladiatorCount}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">WIN/LOSS</CardTitle>
          <Swords className="h-4 w-4 text-slate-500" />
        </CardHeader>
        <CardContent>
          <div className="text-3xl font-bold">
            {stats.wins} / {stats.losses}
          </div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">STAFF</CardTitle>
          <Briefcase className="h-4 w-4 text-slate-500" />
        </CardHeader>
        <CardContent>
          <div className="text-3xl font-bold">{stats.staffCount}</div>
        </CardContent>
      </Card>
    </div>
    <Card>
      <CardHeader>
        <CardTitle>Gladiator Roster Overview</CardTitle>
        <CardDescription>
          Base statistics for all active gladiators.
        </CardDescription>
      </CardHeader>
      <CardContent className="h-[350px]">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart
            data={gladiators.map((g) => ({
              name: g.name.split(" ")[0],
              Strength: g.strength,
              Agility: g.agility,
              Stamina: g.stamina,
            }))}
            margin={{ top: 5, right: 20, left: -10, bottom: 5 }}
          >
            <CartesianGrid
              strokeDasharray="3 3"
              stroke="rgba(128,128,128,0.2)"
            />
            <XAxis dataKey="name" stroke="#888888" />
            <YAxis stroke="#888888" />
            <Tooltip
              contentStyle={{
                backgroundColor: "#1e293b",
                border: "1px solid #334155",
                color: "white",
              }}
              cursor={{ fill: "rgba(100,116,139,0.2)" }}
            />
            <Legend />
            <Bar dataKey="Strength" fill="#38bdf8" radius={[4, 4, 0, 0]} />
            <Bar dataKey="Agility" fill="#a78bfa" radius={[4, 4, 0, 0]} />
            <Bar dataKey="Stamina" fill="#f472b6" radius={[4, 4, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  </div>
);

const GladiatorRoster = ({
  gladiators,
  onTrain,
  onHeal,
  onFire,
  onRename,
  onEditStats,
  onGenerateGossip,
  settings,
  money,
}) => {
  const [renameModal, setRenameModal] = useState({
    isOpen: false,
    gladiator: null,
    newName: "",
  });
  const [editStatsModal, setEditStatsModal] = useState({
    isOpen: false,
    gladiator: null,
    stats: { strength: 0, agility: 0, stamina: 0 },
  });

  const handleOpenRenameModal = (gladiator) =>
    setRenameModal({ isOpen: true, gladiator, newName: gladiator.name });
  const handleCloseRenameModal = () =>
    setRenameModal({ isOpen: false, gladiator: null, newName: "" });
  const handleConfirmRename = () => {
    if (renameModal.gladiator && renameModal.newName.trim()) {
      onRename(renameModal.gladiator.id, renameModal.newName.trim());
      handleCloseRenameModal();
    }
  };

  const handleOpenEditStatsModal = (gladiator) =>
    setEditStatsModal({
      isOpen: true,
      gladiator,
      stats: {
        strength: gladiator.strength,
        agility: gladiator.agility,
        stamina: gladiator.stamina,
      },
    });
  const handleCloseEditStatsModal = () =>
    setEditStatsModal({
      isOpen: false,
      gladiator: null,
      stats: { strength: 0, agility: 0, stamina: 0 },
    });
  const handleConfirmEditStats = () => {
    if (editStatsModal.gladiator) {
      onEditStats(editStatsModal.gladiator.id, editStatsModal.stats);
      handleCloseEditStatsModal();
    }
  };

  return (
    <>
      <Modal
        isOpen={renameModal.isOpen}
        onClose={handleCloseRenameModal}
        title={`Rename ${renameModal.gladiator?.name}`}
      >
        <div className="space-y-4">
          <Label htmlFor="gladiatorName">New Name</Label>
          <Input
            id="gladiatorName"
            value={renameModal.newName}
            onChange={(e) =>
              setRenameModal((prev) => ({ ...prev, newName: e.target.value }))
            }
          />
          <div className="text-right">
            <Button onClick={handleConfirmRename}>Save Name</Button>
          </div>
        </div>
      </Modal>
      <Modal
        isOpen={editStatsModal.isOpen}
        onClose={handleCloseEditStatsModal}
        title={`Edit Stats for ${editStatsModal.gladiator?.name}`}
      >
        <div className="space-y-4">
          <div className="grid grid-cols-3 gap-4">
            <div>
              <Label htmlFor="strength">Strength</Label>
              <Input
                id="strength"
                type="number"
                value={editStatsModal.stats.strength}
                onChange={(e) =>
                  setEditStatsModal((p) => ({
                    ...p,
                    stats: {
                      ...p.stats,
                      strength: parseInt(e.target.value) || 0,
                    },
                  }))
                }
              />
            </div>
            <div>
              <Label htmlFor="agility">Agility</Label>
              <Input
                id="agility"
                type="number"
                value={editStatsModal.stats.agility}
                onChange={(e) =>
                  setEditStatsModal((p) => ({
                    ...p,
                    stats: {
                      ...p.stats,
                      agility: parseInt(e.target.value) || 0,
                    },
                  }))
                }
              />
            </div>
            <div>
              <Label htmlFor="stamina">Stamina</Label>
              <Input
                id="stamina"
                type="number"
                value={editStatsModal.stats.stamina}
                onChange={(e) =>
                  setEditStatsModal((p) => ({
                    ...p,
                    stats: {
                      ...p.stats,
                      stamina: parseInt(e.target.value) || 0,
                    },
                  }))
                }
              />
            </div>
          </div>
          <div className="text-right">
            <Button onClick={handleConfirmEditStats}>Save Stats</Button>
          </div>
        </div>
      </Modal>
      <Card>
        <CardHeader>
          <CardTitle>Gladiator Roster</CardTitle>
          <CardDescription>
            Manage, train, and heal your fighters.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>STR</TableHead>
                <TableHead>AGI</TableHead>
                <TableHead>STM</TableHead>
                <TableHead>Health</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {gladiators.map((g) => {
                const isBusy = g.status !== "Idle" && g.status !== "Injured";
                const healingCost =
                  Math.ceil(g.maxHealth - g.health) * HEALING_COST_PER_HP;
                return (
                  <TableRow key={g.id}>
                    <TableCell className="font-medium flex items-center gap-1">
                      {g.name}
                      <Button
                        variant="ghost"
                        size="icon"
                        className="h-7 w-7"
                        onClick={() => handleOpenRenameModal(g)}
                      >
                        <Edit className="h-3 w-3" />
                      </Button>
                    </TableCell>
                    <TableCell>
                      {g.taskProgress > 0 ? (
                        <div className="w-24">
                          <span className="text-xs font-semibold">
                            {g.status}...
                          </span>
                          <ProgressBar
                            value={g.taskProgress * 100}
                            className="mt-1"
                          />
                        </div>
                      ) : (
                        <span
                          className={`px-2 py-1 text-xs font-semibold rounded-full ${
                            g.status === "Idle"
                              ? "bg-emerald-500/20 text-emerald-500"
                              : "bg-amber-500/20 text-amber-500"
                          }`}
                        >
                          {g.status}
                        </span>
                      )}
                    </TableCell>
                    <TableCell>{g.strength}</TableCell>
                    <TableCell>{g.agility}</TableCell>
                    <TableCell>{g.stamina}</TableCell>
                    <TableCell>
                      <div className="w-24 bg-slate-200 dark:bg-slate-700 rounded-full h-2">
                        <div
                          className="bg-red-500 h-2 rounded-full"
                          style={{
                            width: `${(g.health / g.maxHealth) * 100}%`,
                          }}
                        ></div>
                      </div>
                      <span className="text-xs text-slate-500">
                        {Math.ceil(g.health)}/{g.maxHealth}
                      </span>
                    </TableCell>
                    <TableCell className="flex justify-end gap-1">
                      <Button
                        size="sm"
                        onClick={() => onTrain(g.id)}
                        disabled={isBusy || money < TRAINING_COST}
                      >
                        Train (${TRAINING_COST})
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => onHeal(g.id)}
                        disabled={
                          isBusy ||
                          g.health >= g.maxHealth ||
                          money < healingCost
                        }
                      >
                        Heal (${healingCost})
                      </Button>
                      {settings.useAI && (
                        <Button
                          size="icon"
                          variant="ghost"
                          className="h-9 w-9"
                          onClick={() => onGenerateGossip(g)}
                          disabled={isBusy}
                        >
                          <MessageSquare className="h-4 w-4" />
                        </Button>
                      )}
                      {settings.cheatMode?.enabled && (
                        <Button
                          size="icon"
                          variant="ghost"
                          className="h-9 w-9"
                          onClick={() => handleOpenEditStatsModal(g)}
                          disabled={isBusy}
                        >
                          <Wand2 className="h-4 w-4 text-purple-400" />
                        </Button>
                      )}
                      {gladiators.length > 1 && (
                        <Button
                          size="icon"
                          variant="destructive"
                          className="h-9 w-9"
                          onClick={() => onFire(g.id)}
                          disabled={isBusy}
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      )}
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </>
  );
};

const Arena = ({ gladiators, onFight, onSetGladiatorStatus, staff }) => {
  const [selectedGladiator, setSelectedGladiator] = useState(null);
  const [opponent, setOpponent] = useState(null);
  const [playerCombatStats, setPlayerCombatStats] = useState(null);
  const [isFighting, setIsFighting] = useState(false);
  const [finalLog, setFinalLog] = useState([]);
  const [showLog, setShowLog] = useState(false);

  const scoutBonus = useMemo(
    () => staff.find((s) => s.role === "Scout")?.effect.value || 0,
    [staff]
  );

  const generateOpponent = (playerGlad) => {
    const baseLevel =
      playerGlad.strength + playerGlad.agility + playerGlad.stamina;
    const difficultyMod = 0.9 + Math.random() * 0.2;
    const opponentLevel = baseLevel * difficultyMod;
    let str =
      Math.floor(opponentLevel / 3) + (Math.floor(Math.random() * 6) - 3);
    let agi =
      Math.floor(opponentLevel / 3) + (Math.floor(Math.random() * 6) - 3);
    let stam = opponentLevel - str - agi;
    const health = Math.max(20, stam * 10);
    setOpponent({
      name: `Challenger ${
        ["Gaius", "Titus", "Felix", "Secundus"][Math.floor(Math.random() * 4)]
      }`,
      strength: Math.max(1, str),
      agility: Math.max(1, agi),
      stamina: Math.max(1, stam),
      health,
      maxHealth: health,
    });
  };

  const handleSelectGladiator = (id) => {
    const glad = gladiators.find((g) => g.id === id);
    if (glad) {
      setSelectedGladiator(glad);
      setPlayerCombatStats({ ...glad });
      generateOpponent(glad);
      setFinalLog([]);
      setShowLog(false);
    }
  };

  const startFight = () => {
    if (!playerCombatStats || !opponent) return;
    setIsFighting(true);
    onSetGladiatorStatus(playerCombatStats.id, "Fighting", FIGHT_DURATION);

    let player = { ...playerCombatStats };
    let enemy = { ...opponent };
    let log = [`The fight begins between ${player.name} and ${enemy.name}!`];

    while (player.health > 0 && enemy.health > 0) {
      let pDamage = Math.max(
        1,
        Math.floor(player.strength * (1 + Math.random() * 0.2))
      );
      enemy.health = Math.max(0, enemy.health - pDamage);
      log.push(
        `${player.name} strikes for ${pDamage} damage! (${enemy.health.toFixed(
          0
        )} HP left)`
      );

      if (enemy.health <= 0) break;

      let eDamage = Math.max(
        1,
        Math.floor(enemy.strength * (1 + Math.random() * 0.2))
      );
      player.health = Math.max(0, player.health - eDamage);
      log.push(
        `${
          enemy.name
        } retaliates for ${eDamage} damage! (${player.health.toFixed(
          0
        )} HP left)`
      );
    }

    const result = player.health > 0 ? "win" : "loss";
    log.push(
      result === "win"
        ? `${player.name} is victorious!`
        : `${player.name} has been defeated!`
    );

    setTimeout(() => {
      setIsFighting(false);
      setFinalLog(log);
      onFight(player.id, result, player.health, log);
    }, FIGHT_DURATION);
  };

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div className="md:col-span-1 space-y-6">
        <Card>
          <CardHeader>
            <CardTitle>Choose Champion</CardTitle>
          </CardHeader>
          <CardContent className="space-y-2">
            {gladiators
              .filter((g) => g.status === "Idle")
              .map((g) => (
                <Button
                  key={g.id}
                  variant={
                    selectedGladiator?.id === g.id ? "default" : "outline"
                  }
                  className="w-full justify-start"
                  onClick={() => handleSelectGladiator(g.id)}
                >
                  {g.name}
                </Button>
              ))}
            {gladiators.filter((g) => g.status === "Idle").length === 0 && (
              <p className="text-sm text-slate-500">
                All gladiators are busy or injured.
              </p>
            )}
          </CardContent>
        </Card>
        {opponent && !isFighting && (
          <Card>
            <CardHeader>
              <CardTitle>Opponent</CardTitle>
              <CardDescription>Scouting report</CardDescription>
            </CardHeader>
            <CardContent>
              <p className="font-bold">{opponent.name}</p>
              <p>
                STR: {Math.round(opponent.strength * (1 - scoutBonus))} -{" "}
                {Math.round(opponent.strength * (1 + scoutBonus))}
              </p>
              <p>
                AGI: {Math.round(opponent.agility * (1 - scoutBonus))} -{" "}
                {Math.round(opponent.agility * (1 + scoutBonus))}
              </p>
              <p>
                STM: {Math.round(opponent.stamina * (1 - scoutBonus))} -{" "}
                {Math.round(opponent.stamina * (1 + scoutBonus))}
              </p>
            </CardContent>
          </Card>
        )}
      </div>
      <div className="md:col-span-2">
        <Card>
          <CardHeader>
            <CardTitle>The Arena</CardTitle>
          </CardHeader>
          <CardContent>
            {!selectedGladiator ? (
              <p className="text-slate-500 text-center py-10">
                Select a gladiator to see the matchup.
              </p>
            ) : (
              <div>
                <div className="grid grid-cols-2 gap-4 mb-4 text-center">
                  <div>
                    <h4 className="font-bold">{selectedGladiator.name}</h4>
                    <p>
                      HP: {Math.ceil(selectedGladiator.health)}/
                      {selectedGladiator.maxHealth}
                    </p>
                  </div>
                  {opponent && (
                    <div>
                      <h4 className="font-bold">{opponent.name}</h4>
                      <p>
                        HP: {Math.ceil(opponent.health)}/{opponent.maxHealth}
                      </p>
                    </div>
                  )}
                </div>
                {!isFighting && (
                  <Button
                    onClick={startFight}
                    disabled={isFighting || !selectedGladiator}
                    className="w-full"
                  >
                    <Swords className="mr-2 h-4 w-4" /> Begin Fight
                  </Button>
                )}
                {finalLog.length > 0 && (
                  <div className="mt-4">
                    <Button
                      variant="ghost"
                      className="w-full"
                      onClick={() => setShowLog(!showLog)}
                    >
                      {showLog ? "Hide Details" : "Show Details"}
                      {showLog ? (
                        <ChevronUp className="ml-2 h-4 w-4" />
                      ) : (
                        <ChevronDown className="ml-2 h-4 w-4" />
                      )}
                    </Button>
                    {showLog && (
                      <div className="mt-2 p-4 h-48 bg-slate-100 dark:bg-slate-900 rounded-md overflow-y-auto">
                        <ul className="space-y-1 text-sm font-mono">
                          {finalLog.map((entry, index) => (
                            <li key={index}>{entry}</li>
                          ))}
                        </ul>
                      </div>
                    )}
                  </div>
                )}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

const Recruiting = ({
  money,
  onHire,
  availableStaff,
  onGenerateStaff,
  settings,
}) => (
  <Card>
    <CardHeader className="flex justify-between items-center">
      <div>
        <CardTitle>Recruiting Office</CardTitle>
        <CardDescription>
          Hire skilled professionals to support your ludus.
        </CardDescription>
      </div>
      <Button
        onClick={onGenerateStaff}
        disabled={settings.useAI && !settings.apiKey}
      >
        <BrainCircuit className="mr-2 h-4 w-4" /> Generate Candidate
      </Button>
    </CardHeader>
    <CardContent>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Name</TableHead>
            <TableHead>Role</TableHead>
            <TableHead>Hiring Cost</TableHead>
            <TableHead>Effect</TableHead>
            <TableHead>Action</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {availableStaff.map((s) => (
            <TableRow key={s.id || s.name}>
              <TableCell>{s.name}</TableCell>
              <TableCell>{s.role}</TableCell>
              <TableCell>${s.cost}</TableCell>
              <TableCell className="text-xs">
                {s.effect.type.replace("_", " ")} +
                {(s.effect.value * 100).toFixed(0)}%
              </TableCell>
              <TableCell>
                <Button
                  size="sm"
                  onClick={() => onHire(s)}
                  disabled={money < s.cost}
                >
                  Hire
                </Button>
              </TableCell>
            </TableRow>
          ))}
          {availableStaff.length === 0 && (
            <TableRow>
              <TableCell
                colSpan="5"
                className="text-center text-slate-500 py-10"
              >
                No candidates available. Generate one!
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </CardContent>
  </Card>
);

const Shop = ({ onGenerateGladiator, money, settings }) => (
  <Card>
    <CardHeader className="flex justify-between items-center">
      <div>
        <CardTitle>Gladiator Market</CardTitle>
        <CardDescription>
          Recruit new blood for your arena team. Base cost is $250.
        </CardDescription>
      </div>
      <Button onClick={onGenerateGladiator} disabled={money < 250}>
        {settings.useAI ? (
          <BrainCircuit className="mr-2 h-4 w-4" />
        ) : (
          <UserPlus className="mr-2 h-4 w-4" />
        )}
        Recruit Gladiator
      </Button>
    </CardHeader>
    <CardContent>
      <p className="text-center text-slate-500 py-10">
        Use the recruit button to find a new gladiator.
      </p>
    </CardContent>
  </Card>
);

const SettingsPanel = ({ settings, onSettingsChange }) => (
  <Card>
    <CardHeader>
      <CardTitle>Settings</CardTitle>
      <CardDescription>
        Configure game settings and AI integrations.
      </CardDescription>
    </CardHeader>
    <CardContent className="space-y-6">
      <div className="flex items-center justify-between p-4 rounded-lg bg-slate-100 dark:bg-slate-900/50">
        <Label htmlFor="ai-toggle" className="flex-grow">
          <span className="font-semibold flex items-center">
            <BrainCircuit className="mr-2 h-4 w-4" /> Use AI for Generation
          </span>
          <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
            Enable to use AI for generating names and epic combat summaries.
          </p>
        </Label>
        <Switch
          id="ai-toggle"
          checked={settings.useAI}
          onCheckedChange={(checked) =>
            onSettingsChange({ ...settings, useAI: checked })
          }
        />
      </div>
      {settings.useAI && (
        <div className="space-y-2">
          <Label htmlFor="api-key">Gemini API Key</Label>
          <Input
            id="api-key"
            type="password"
            placeholder="Enter your API key"
            value={settings.apiKey}
            onChange={(e) =>
              onSettingsChange({ ...settings, apiKey: e.target.value })
            }
          />
          <p className="text-xs text-slate-500 dark:text-slate-400">
            Your API key is stored locally and used only for game content
            generation.
          </p>
        </div>
      )}
      <div className="border-t border-slate-200 dark:border-slate-700 my-6"></div>
      <div className="flex items-center justify-between p-4 rounded-lg bg-slate-100 dark:bg-slate-900/50">
        <Label htmlFor="cheat-toggle" className="flex-grow">
          <span className="font-semibold flex items-center text-purple-500">
            <Wand2 className="mr-2 h-4 w-4" /> Cheat Mode
          </span>
          <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
            Unlock special settings to modify game rules.
          </p>
        </Label>
        <Switch
          id="cheat-toggle"
          checked={settings.cheatMode?.enabled}
          onCheckedChange={(checked) =>
            onSettingsChange({
              ...settings,
              cheatMode: { ...settings.cheatMode, enabled: checked },
            })
          }
        />
      </div>
      {settings.cheatMode?.enabled && (
        <Card className="bg-purple-900/10 border-purple-500/30">
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between">
              <Label htmlFor="double-training">
                <span className="font-medium">Double Training Gain</span>
                <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
                  Training provides +2 stats instead of +1.
                </p>
              </Label>
              <Switch
                id="double-training"
                checked={settings.cheatMode.doubleTrainingGain}
                onCheckedChange={(c) =>
                  onSettingsChange({
                    ...settings,
                    cheatMode: { ...settings.cheatMode, doubleTrainingGain: c },
                  })
                }
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="win-chance">
                <span className="font-medium">
                  Post-Fight Stat Gain Chance:{" "}
                  {settings.cheatMode.postFightStatChance}%
                </span>
                <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
                  Chance for a gladiator to gain a stat point after a win.
                </p>
              </Label>
              <Input
                type="range"
                id="win-chance"
                min="0"
                max="100"
                value={settings.cheatMode.postFightStatChance}
                onChange={(e) =>
                  onSettingsChange({
                    ...settings,
                    cheatMode: {
                      ...settings.cheatMode,
                      postFightStatChance: parseInt(e.target.value),
                    },
                  })
                }
              />
            </div>
          </CardContent>
        </Card>
      )}
    </CardContent>
  </Card>
);

// --- MAIN APP COMPONENT ---
export default function App() {
  const [page, setPage] = useState("dashboard");
  const [money, setMoney] = useState(1000);
  const [gladiators, setGladiators] = useState([]);
  const [staff, setStaff] = useState([]);
  const [availableStaff, setAvailableStaff] = useState([]);
  const [gameStats, setGameStats] = useState({
    wins: 0,
    losses: 0,
    nameCounter: 0,
  });
  const [settings, setSettings] = useState({
    useAI: false,
    apiKey: "",
    cheatMode: {
      enabled: false,
      doubleTrainingGain: false,
      postFightStatChance: 60,
    },
  });
  const [modal, setModal] = useState({ isOpen: false, title: "", content: "" });
  const [isInitialLoad, setIsInitialLoad] = useState(true);
  const [isApiLoading, setIsApiLoading] = useState(false);
  const [isMenuCollapsed, setIsMenuCollapsed] = useState(false);

  const createGladiator = (name) => {
    const stam = 5 + Math.floor(Math.random() * 6);
    return {
      id: Date.now() + Math.random(),
      name,
      strength: 5 + Math.floor(Math.random() * 6),
      agility: 5 + Math.floor(Math.random() * 6),
      stamina: stam,
      health: stam * 10,
      maxHealth: stam * 10,
      status: "Idle",
      taskStartTime: null,
      taskDuration: null,
      taskProgress: 0,
      lastPassiveHeal: 0,
    };
  };

  const initialGameState = useCallback(() => {
    setMoney(1000);
    setGladiators([createGladiator("Player One")]);
    setStaff([]);
    setAvailableStaff(STATIC_STAFF_CANDIDATES.slice(0, 3));
    setGameStats({ wins: 0, losses: 0, nameCounter: 0 });
    setSettings({
      useAI: false,
      apiKey: "",
      cheatMode: {
        enabled: false,
        doubleTrainingGain: false,
        postFightStatChance: 60,
      },
    });
    console.log("New game started.");
  }, []);

  useEffect(() => {
    try {
      const savedState = localStorage.getItem("gladiatorGameState");
      if (savedState) {
        const state = JSON.parse(savedState);
        if (state.gladiators && state.gladiators.length > 0) {
          setMoney(state.money);
          setGladiators(state.gladiators);
          setStaff(state.staff);
          setGameStats(state.gameStats);
          setAvailableStaff(state.availableStaff);
          setSettings(
            state.settings || {
              useAI: false,
              apiKey: "",
              cheatMode: {
                enabled: false,
                doubleTrainingGain: false,
                postFightStatChance: 60,
              },
            }
          ); // Ensure settings exist
        } else {
          initialGameState();
        }
      } else {
        initialGameState();
      }
    } catch (error) {
      console.error("Failed to load game state, starting new game:", error);
      initialGameState();
    }
    setIsInitialLoad(false);
  }, [initialGameState]);

  useEffect(() => {
    if (isInitialLoad) return;
    try {
      const gameState = {
        money,
        gladiators,
        staff,
        gameStats,
        availableStaff,
        settings,
      };
      localStorage.setItem("gladiatorGameState", JSON.stringify(gameState));
    } catch (error) {
      console.error("Failed to save game state:", error);
    }
  }, [
    money,
    gladiators,
    staff,
    gameStats,
    availableStaff,
    settings,
    isInitialLoad,
  ]);

  useEffect(() => {
    const gameTick = setInterval(() => {
      let needsUpdate = false;
      const now = Date.now();
      const updatedGladiators = gladiators.map((g) => {
        let newGlad = { ...g };
        if (
          g.taskStartTime &&
          (g.status === "Training" ||
            g.status === "Healing" ||
            g.status === "Fighting")
        ) {
          needsUpdate = true;
          const progress = (now - g.taskStartTime) / g.taskDuration;
          newGlad.taskProgress = progress;
          if (progress >= 1) {
            newGlad = {
              ...newGlad,
              taskProgress: 0,
              taskStartTime: null,
              taskDuration: null,
            };
            if (g.status === "Training") {
              newGlad.status = "Idle";
              const statBoost = ["strength", "agility", "stamina"][
                Math.floor(Math.random() * 3)
              ];
              const gain =
                settings.cheatMode?.enabled &&
                settings.cheatMode?.doubleTrainingGain
                  ? 2
                  : 1;
              newGlad[statBoost] += gain;
              if (statBoost === "stamina")
                newGlad.maxHealth = newGlad.stamina * 10;
              newGlad.health = newGlad.maxHealth;
            }
            if (g.status === "Healing") {
              newGlad.status = "Idle";
              newGlad.health = newGlad.maxHealth;
            }
          }
        } else if (
          (g.status === "Idle" || g.status === "Injured") &&
          g.health < g.maxHealth &&
          now > (g.lastPassiveHeal || 0) + PASSIVE_HEAL_INTERVAL
        ) {
          needsUpdate = true;
          newGlad.health = Math.min(
            g.maxHealth,
            g.health + PASSIVE_HEAL_AMOUNT
          );
          newGlad.lastPassiveHeal = now;
          if (
            newGlad.health >= newGlad.maxHealth &&
            newGlad.status === "Injured"
          )
            newGlad.status = "Idle";
        }
        return newGlad;
      });
      if (needsUpdate) setGladiators(updatedGladiators);
    }, 1000);
    return () => clearInterval(gameTick);
  }, [gladiators, settings.cheatMode]);

  const generateAiContent = async (prompt) => {
    if (!settings.useAI || !settings.apiKey) {
      setModal({
        isOpen: true,
        title: "AI Error",
        content: "AI is not enabled or API key is missing.",
      });
      return null;
    }
    setIsApiLoading(true);
    try {
      const API_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${settings.apiKey}`;
      const response = await fetch(API_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }),
      });
      if (!response.ok)
        throw new Error(`API request failed: ${response.status}`);
      const data = await response.json();
      return data.candidates[0].content.parts[0].text.trim().replace(/\"/g, "");
    } catch (error) {
      setModal({
        isOpen: true,
        title: "AI Error",
        content: `Failed to generate content: ${error.message}`,
      });
      return null;
    } finally {
      setIsApiLoading(false);
    }
  };

  const handleGenerateGladiator = async () => {
    if (money < 250) {
      return;
    }
    let name;
    if (settings.useAI) {
      name = await generateAiContent(
        "Generate a single, cool, roman-sounding gladiator name."
      );
      if (!name) return;
    } else {
      name = `${
        STATIC_GLADIATOR_NAMES[
          gameStats.nameCounter % STATIC_GLADIATOR_NAMES.length
        ]
      } ${
        Math.floor(gameStats.nameCounter / STATIC_GLADIATOR_NAMES.length) > 0
          ? Math.floor(gameStats.nameCounter / STATIC_GLADIATOR_NAMES.length) +
            1
          : ""
      }`;
      setGameStats((prev) => ({ ...prev, nameCounter: prev.nameCounter + 1 }));
    }
    setGladiators((prev) => [...prev, createGladiator(name)]);
    setMoney((prev) => prev - 250);
    setModal({
      isOpen: true,
      title: "Recruitment Successful",
      content: `Welcome to the ludus, ${name}!`,
    });
  };

  const handleGenerateGossip = async (gladiator) => {
    const otherGladiators = gladiators
      .filter((g) => g.id !== gladiator.id)
      .map((g) => g.name);
    if (otherGladiators.length === 0) {
      setModal({
        isOpen: true,
        title: "Gossip",
        content: `${gladiator.name} mutters to themself. They are lonely.`,
      });
      return;
    }
    const prompt = `I am the gladiator named ${
      gladiator.name
    }. My comrades are ${otherGladiators.join(
      ", "
    )}. Write a short, one-sentence piece of gossip or a boastful comment I might say about myself or one of them. Keep it brief and in character.`;
    const gossip = await generateAiContent(prompt);
    if (gossip) {
      setModal({
        isOpen: true,
        title: `${gladiator.name} says...`,
        content: `"${gossip}"`,
      });
    }
  };

  const handleGenerateStaff = async () => {
    let newStaff;
    if (settings.useAI) {
      const prompt = `Generate a name and a role for a gladiator support staff member (e.g., 'Marcus the Medic', 'Julius the Drillmaster'). Respond in the format 'Name, Role'. Provide only the text, no markdown.`;
      const result = await generateAiContent(prompt);
      if (result) {
        const [name, role] = result.split(",").map((s) => s.trim());
        if (name && role) {
          newStaff = {
            id: Date.now(),
            name,
            role,
            cost: 300 + Math.floor(Math.random() * 500),
            effect: {
              type: ["training_speed", "healing_speed"][
                Math.floor(Math.random() * 2)
              ],
              value: 0.05 + Math.random() * 0.1,
            },
          };
        }
      }
    } else {
      const unhired = STATIC_STAFF_CANDIDATES.filter(
        (sc) =>
          !staff.some((s) => s.name === sc.name) &&
          !availableStaff.some((a) => a.name === sc.name)
      );
      if (unhired.length > 0)
        newStaff = unhired[Math.floor(Math.random() * unhired.length)];
      else {
        setModal({
          isOpen: true,
          title: "No More Staff",
          content: "All available static staff have been hired or are listed.",
        });
        return;
      }
    }
    if (newStaff) setAvailableStaff((prev) => [newStaff, ...prev]);
  };

  const handleTrain = (id) => {
    if (money < TRAINING_COST) {
      setModal({
        isOpen: true,
        title: "Insufficient Funds",
        content: `You need $${TRAINING_COST} to train.`,
      });
      return;
    }
    setMoney((m) => m - TRAINING_COST);
    setGladiators((glads) =>
      glads.map((g) =>
        g.id === id
          ? {
              ...g,
              status: "Training",
              taskStartTime: Date.now(),
              taskDuration: 10000,
              taskProgress: 0,
            }
          : g
      )
    );
  };

  const handleHeal = (id) => {
    const glad = gladiators.find((g) => g.id === id);
    if (!glad) return;
    const cost = Math.ceil(glad.maxHealth - glad.health) * HEALING_COST_PER_HP;
    if (money < cost) {
      setModal({
        isOpen: true,
        title: "Insufficient Funds",
        content: `You need $${cost} to heal.`,
      });
      return;
    }
    setMoney((m) => m - cost);
    setGladiators((glads) =>
      glads.map((g) =>
        g.id === id
          ? {
              ...g,
              status: "Healing",
              taskStartTime: Date.now(),
              taskDuration: (g.maxHealth - g.health) * 200,
              taskProgress: 0,
            }
          : g
      )
    );
  };

  const handleFire = (id) => {
    const firedGlad = gladiators.find((g) => g.id === id);
    if (gladiators.length > 1 && firedGlad) {
      setGladiators((glads) => glads.filter((g) => g.id !== id));
      setModal({
        isOpen: true,
        title: "Gladiator Dismissed",
        content: `${firedGlad.name} has been released from service.`,
      });
    }
  };

  const handleRenameGladiator = (id, newName) => {
    setGladiators((glads) =>
      glads.map((g) => (g.id === id ? { ...g, name: newName } : g))
    );
  };

  const setGladiatorStatus = (id, status, duration) => {
    setGladiators((glads) =>
      glads.map((g) =>
        g.id === id
          ? {
              ...g,
              status,
              taskStartTime: Date.now(),
              taskDuration: duration,
              taskProgress: 0,
            }
          : g
      )
    );
  };

  const handleEditGladiatorStats = (id, newStats) => {
    setGladiators((glads) =>
      glads.map((g) => {
        if (g.id === id) {
          const newStamina = newStats.stamina;
          const healthPercentage = g.health / g.maxHealth;
          const newMaxHealth = newStamina * 10;
          return {
            ...g,
            ...newStats,
            maxHealth: newMaxHealth,
            health: newMaxHealth * healthPercentage,
          };
        }
        return g;
      })
    );
  };

  const handleFight = async (id, result, finalHealth, fightLog) => {
    const fightReward = 200;
    const accountantBonus =
      staff.find((s) => s.role === "Accountant")?.effect.value || 0;
    let modalContent = "";
    let modalTitle = result === "win" ? "Victory!" : "Defeat!";
    let statGainText = "";

    let updatedGladiators = gladiators.map((g) =>
      g.id === id
        ? {
            ...g,
            status: finalHealth > 0 ? "Idle" : "Injured",
            health: finalHealth,
            taskProgress: 0,
            taskStartTime: null,
            taskDuration: null,
          }
        : g
    );

    if (result === "win") {
      setMoney((m) => m + Math.floor(fightReward * (1 + accountantBonus)));
      setGameStats((s) => ({ ...s, wins: s.wins + 1 }));

      const winChance = settings.cheatMode?.enabled
        ? settings.cheatMode.postFightStatChance
        : 60;
      if (Math.random() * 100 < winChance) {
        updatedGladiators = updatedGladiators.map((g) => {
          if (g.id === id) {
            const statBoost = ["strength", "agility", "stamina"][
              Math.floor(Math.random() * 3)
            ];
            statGainText = `\n\nThrough the glory of combat, their ${statBoost} has increased!`;
            const newGlad = { ...g, [statBoost]: g[statBoost] + 1 };
            if (statBoost === "stamina") {
              newGlad.maxHealth = newGlad.stamina * 10;
              newGlad.health = Math.min(newGlad.maxHealth, newGlad.health + 10);
            }
            return newGlad;
          }
          return g;
        });
      }
    } else {
      setGameStats((s) => ({ ...s, losses: s.losses + 1 }));
    }

    if (settings.useAI && fightLog) {
      const winnerName =
        result === "win"
          ? gladiators.find((g) => g.id === id)?.name
          : "The Challenger";
      const loserName =
        result === "loss"
          ? gladiators.find((g) => g.id === id)?.name
          : "The Challenger";
      const prompt = `The following is a turn-by-turn log from a gladiator fight. Rewrite it as a short, epic, and dramatic summary of the battle (2-3 sentences). The victor was ${winnerName} and the loser was ${loserName}. Make the victor sound heroic and the loser valiant in defeat.\n\nLOG:\n${fightLog.join(
        "\n"
      )}`;
      const summary = await generateAiContent(prompt);
      modalContent =
        (summary ||
          (result === "win"
            ? "A glorious victory!"
            : "A valiant effort in defeat.")) + statGainText;
    } else {
      modalContent =
        (result === "win"
          ? `You earned $${Math.floor(fightReward * (1 + accountantBonus))}!`
          : "Your gladiator has been injured.") + statGainText;
    }

    setGladiators(updatedGladiators);
    setModal({ isOpen: true, title: modalTitle, content: modalContent });
  };

  const handleHireStaff = (staffMember) => {
    if (money >= staffMember.cost) {
      setMoney((m) => m - staffMember.cost);
      setStaff((s) => [...s, staffMember]);
      setAvailableStaff((a) =>
        a.filter(
          (s) => (s.id || s.name) !== (staffMember.id || staffMember.name)
        )
      );
      setModal({
        isOpen: true,
        title: "Staff Hired",
        content: `${staffMember.name} the ${staffMember.role} has joined your team.`,
      });
    }
  };

  const renderPage = () => {
    switch (page) {
      case "dashboard":
        return (
          <Dashboard
            stats={{
              money,
              gladiatorCount: gladiators.length,
              wins: gameStats.wins,
              losses: gameStats.losses,
              staffCount: staff.length,
            }}
            gladiators={gladiators}
          />
        );
      case "gladiators":
        return (
          <GladiatorRoster
            gladiators={gladiators}
            onTrain={handleTrain}
            onHeal={handleHeal}
            onFire={handleFire}
            onRename={handleRenameGladiator}
            onEditStats={handleEditGladiatorStats}
            onGenerateGossip={handleGenerateGossip}
            settings={settings}
            money={money}
          />
        );
      case "arena":
        return (
          <Arena
            gladiators={gladiators}
            onFight={handleFight}
            onSetGladiatorStatus={setGladiatorStatus}
            staff={staff}
          />
        );
      case "shop":
        return (
          <Shop
            onGenerateGladiator={handleGenerateGladiator}
            money={money}
            settings={settings}
          />
        );
      case "recruiting":
        return (
          <Recruiting
            money={money}
            onHire={handleHireStaff}
            availableStaff={availableStaff}
            onGenerateStaff={handleGenerateStaff}
            settings={settings}
          />
        );
      case "settings":
        return (
          <SettingsPanel settings={settings} onSettingsChange={setSettings} />
        );
      default:
        return <Dashboard />;
    }
  };

  const NavButton = ({ target, icon, label, isCollapsed }) => (
    <button
      onClick={() => setPage(target)}
      title={label}
      className={`w-full flex items-center p-3 rounded-lg transition-colors text-slate-300 hover:bg-slate-700 hover:text-white relative ${
        page === target ? "bg-slate-700 text-white" : ""
      } ${isCollapsed ? "justify-center" : ""}`}
    >
      {page === target && (
        <span className="absolute left-0 top-1/2 -translate-y-1/2 h-6 w-1 bg-sky-500 rounded-r-full"></span>
      )}
      {icon}
      {!isCollapsed && <span className="ml-4 font-semibold">{label}</span>}
    </button>
  );

  return (
    <div className="bg-slate-100 dark:bg-slate-900 text-slate-800 dark:text-slate-200 min-h-screen font-sans flex overflow-hidden">
      {isApiLoading && <ApiLoadingChip />}
      <Modal
        isOpen={modal.isOpen}
        onClose={() => setModal({ ...modal, isOpen: false })}
        title={modal.title}
      >
        <div>{modal.content}</div>
        <div className="text-right mt-6">
          <Button onClick={() => setModal({ ...modal, isOpen: false })}>
            Close
          </Button>
        </div>
      </Modal>

      <aside
        className={`bg-slate-800 dark:bg-slate-950 p-4 flex flex-col flex-shrink-0 min-h-screen border-r border-slate-200 dark:border-slate-800 transition-all duration-300 ${
          isMenuCollapsed ? "w-20" : "w-64"
        }`}
      >
        <div className="flex items-center gap-3 mb-8 px-2">
          <Shield className="h-9 w-9 text-sky-500 flex-shrink-0" />
          {!isMenuCollapsed && (
            <h1 className="text-2xl font-bold text-white tracking-tight">
              Ludus
            </h1>
          )}
        </div>
        <nav className="space-y-2 flex-grow">
          <NavButton
            target="dashboard"
            icon={<Users className="h-5 w-5" />}
            label="Dashboard"
            isCollapsed={isMenuCollapsed}
          />
          <NavButton
            target="gladiators"
            icon={<Users className="h-5 w-5" />}
            label="Gladiators"
            isCollapsed={isMenuCollapsed}
          />
          <NavButton
            target="arena"
            icon={<Swords className="h-5 w-5" />}
            label="Arena"
            isCollapsed={isMenuCollapsed}
          />
          <NavButton
            target="shop"
            icon={<UserPlus className="h-5 w-5" />}
            label="Recruit"
            isCollapsed={isMenuCollapsed}
          />
          <NavButton
            target="recruiting"
            icon={<Briefcase className="h-5 w-5" />}
            label="Staff"
            isCollapsed={isMenuCollapsed}
          />
          <NavButton
            target="settings"
            icon={<Settings className="h-5 w-5" />}
            label="Settings"
            isCollapsed={isMenuCollapsed}
          />
        </nav>
        <div className="mt-auto">
          <Button
            variant="ghost"
            className="w-full text-slate-400"
            onClick={() => setIsMenuCollapsed(!isMenuCollapsed)}
          >
            {isMenuCollapsed ? (
              <ChevronsRight className="h-5 w-5" />
            ) : (
              <ChevronsLeft className="h-5 w-5" />
            )}
          </Button>
        </div>
      </aside>
      <main className="flex-1 p-6 sm:p-8 lg:p-10 overflow-y-auto">
        {renderPage()}
      </main>
    </div>
  );
}
